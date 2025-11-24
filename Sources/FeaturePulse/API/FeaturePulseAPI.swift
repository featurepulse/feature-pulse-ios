import SwiftUI

/// API response wrapper
private struct APIResponse<T: Codable>: Codable {
  let success: Bool
  let data: T
}

private struct FeatureRequestsResponse: Codable {
  let success: Bool
  let data: [FeatureRequest]
  let showStatus: Bool?
  let showSdkEmailField: Bool?

  enum CodingKeys: String, CodingKey {
    case success, data
    case showStatus = "show_status"
    case showSdkEmailField = "show_sdk_email_field"
  }
}

/// API client for communicating with FeaturePulse backend
public final class FeaturePulseAPI: Sendable {
  public static let shared = FeaturePulseAPI()

  private let session = URLSession.shared

  private init() {}

  // MARK: - Fetch Feature Requests

  /// Fetches all feature requests for the configured project
  public func fetchFeatureRequests() async throws -> [FeatureRequest] {
    let config = FeaturePulseConfiguration.shared

    guard !config.apiKey.isEmpty else {
      throw FeaturePulseError.missingAPIKey
    }

    // Add device_id query parameter for filtering pending requests
    var urlComponents = URLComponents(string: "\(config.baseURL)/api/sdk/feature-requests")
    urlComponents?.queryItems = [
      URLQueryItem(name: "device_id", value: config.user.deviceID)
    ]

    guard let url = urlComponents?.url else {
      throw FeaturePulseError.invalidURL
    }

    var request = URLRequest(url: url)
    request.addValue(config.apiKey, forHTTPHeaderField: "X-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw FeaturePulseError.invalidResponse
    }

    guard httpResponse.statusCode == 200 else {
      throw FeaturePulseError.serverError(httpResponse.statusCode)
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let apiResponse = try decoder.decode(FeatureRequestsResponse.self, from: data)

    // Update configuration with settings from server
    if let showStatus = apiResponse.showStatus {
      config.showStatus = showStatus
    }
    if let showSdkEmailField = apiResponse.showSdkEmailField {
      config.showSdkEmailField = showSdkEmailField
    }

    return apiResponse.data
  }

  // MARK: - Submit Feature Request

  /// Submits a new feature request
  public func submitFeatureRequest(
    title: String,
    description: String,
    email: String? = nil
  ) async throws {
    let config = FeaturePulseConfiguration.shared

    guard !config.apiKey.isEmpty else {
      throw FeaturePulseError.missingAPIKey
    }

    // If email is provided and different from current, update user configuration
    if let email = email, !email.isEmpty, email != config.user.email {
      config.user.email = email
    }

    let urlString = "\(config.baseURL)/api/sdk/feature-requests"
    guard let url = URL(string: urlString) else {
      throw FeaturePulseError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue(config.apiKey, forHTTPHeaderField: "X-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Use user information from configuration
    let deviceInfo: [String: Any] = [
      "device_id": config.user.deviceID,
      "bundle_id": Bundle.main.bundleIdentifier ?? "unknown"
    ]

    var body: [String: Any] = [
      "title": title,
      "description": description,
      "device_info": deviceInfo
    ]

    // Only include email and name if they exist
    if let email = config.user.email, !email.isEmpty {
      body["user_email"] = email
    }
    if let name = config.user.name, !name.isEmpty {
      body["user_name"] = name
    }

    // Include payment information if available
    if let payment = config.user.payment {
      body["payment_type"] = payment.paymentType.rawValue
      body["monthly_value_cents"] = payment.monthlyValueInCents
      body["original_amount_cents"] =
        NSDecimalNumber(decimal: payment.originalAmount * 100).intValue
    }

    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (_, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw FeaturePulseError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw FeaturePulseError.serverError(httpResponse.statusCode)
    }
  }

  // MARK: - Vote for Feature Request

  /// Votes for a feature request
  public func voteForFeatureRequest(id: String) async throws {
    let config = FeaturePulseConfiguration.shared

    guard !config.apiKey.isEmpty else {
      throw FeaturePulseError.missingAPIKey
    }

    let urlString = "\(config.baseURL)/api/sdk/feature-requests/\(id)/vote"
    guard let url = URL(string: urlString) else {
      throw FeaturePulseError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue(config.apiKey, forHTTPHeaderField: "X-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Send device_id to track votes per user and payment info for MRR tracking
    var body: [String: Any] = [
      "device_id": config.user.deviceID
    ]

    // Include payment information if available
    if let payment = config.user.payment {
      body["payment_type"] = payment.paymentType.rawValue
      body["monthly_value_cents"] = payment.monthlyValueInCents
    }

    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (_, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw FeaturePulseError.invalidResponse
    }

    // Handle duplicate vote (409 Conflict)
    if httpResponse.statusCode == 409 {
      throw FeaturePulseError.alreadyVoted
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw FeaturePulseError.serverError(httpResponse.statusCode)
    }
  }

  // MARK: - Update User

  /// Syncs user information including payment data to the backend
  public func syncUser() async throws {
    let config = FeaturePulseConfiguration.shared

    guard !config.apiKey.isEmpty else {
      throw FeaturePulseError.missingAPIKey
    }

    let urlString = "\(config.baseURL)/api/sdk/user"
    guard let url = URL(string: urlString) else {
      throw FeaturePulseError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue(config.apiKey, forHTTPHeaderField: "X-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Prepare user data
    var body: [String: Any] = [
      "user_identifier": config.user.userIdentifier
    ]

    if let customID = config.user.customID {
      body["custom_id"] = customID
    }
    if let email = config.user.email {
      body["user_email"] = email
    }
    if let name = config.user.name {
      body["user_name"] = name
    }

    // Include payment information if available
    if let payment = config.user.payment {
      body["payment_type"] = payment.paymentType.rawValue
      body["monthly_value_cents"] = payment.monthlyValueInCents
      body["original_amount_cents"] =
        NSDecimalNumber(decimal: payment.originalAmount * 100).intValue
    }

    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw FeaturePulseError.invalidResponse
    }

    if !(200...299).contains(httpResponse.statusCode) {
      throw FeaturePulseError.serverError(httpResponse.statusCode)
    }
  }

  /// Removes vote from a feature request
  public func unvoteForFeatureRequest(id: String) async throws {
    let config = FeaturePulseConfiguration.shared

    guard !config.apiKey.isEmpty else {
      throw FeaturePulseError.missingAPIKey
    }

    let urlString = "\(config.baseURL)/api/sdk/feature-requests/\(id)/vote"
    guard let url = URL(string: urlString) else {
      throw FeaturePulseError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.addValue(config.apiKey, forHTTPHeaderField: "X-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Send device_id to identify which vote to remove
    let body: [String: Any] = [
      "device_id": config.user.deviceID
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (_, response) = try await session.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw FeaturePulseError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw FeaturePulseError.serverError(httpResponse.statusCode)
    }
  }
}

// MARK: - Errors

/// Errors that can occur when using the FeaturePulse API
public enum FeaturePulseError: LocalizedError, Equatable {
  case missingAPIKey
  case invalidURL
  case invalidResponse
  case serverError(Int)
  case decodingError
  case alreadyVoted

  public var errorDescription: String? {
    switch self {
    case .missingAPIKey:
      return "API key is required. Set it in FeaturePulseConfiguration.shared.apiKey"
    case .invalidURL:
      return "Invalid URL"
    case .invalidResponse:
      return "Invalid response from server"
    case .serverError(let code):
      return "Server error: \(code)"
    case .decodingError:
      return "Failed to decode response"
    case .alreadyVoted:
      return "You have already voted for this feature request"
    }
  }
}
