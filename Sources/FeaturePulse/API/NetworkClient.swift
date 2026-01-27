import Foundation

/// Core networking client for making API requests
final class NetworkClient: Sendable {
    static let shared = NetworkClient()

    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        session = URLSession(configuration: configuration)

        encoder = JSONEncoder()

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Public Interface

    /// Performs an API request and decodes the response
    /// - Parameters:
    ///   - endpoint: The API endpoint to call
    ///   - body: Optional request body (Encodable)
    ///   - queryItems: Optional query parameters
    /// - Returns: Decoded response of type T
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: (some Encodable)? = nil as Empty?,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        let config = FeaturePulse.shared

        guard !config.apiKey.isEmpty else {
            throw FeaturePulseError.missingAPIKey
        }

        guard let url = endpoint.url(baseURL: config.baseURL, queryItems: queryItems) else {
            throw FeaturePulseError.invalidURL
        }

        var request = buildRequest(url: url, method: endpoint.method, apiKey: config.apiKey)

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        try validateResponse(response, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw FeaturePulseError.decodingError
        }
    }

    /// Performs an API request without expecting a response body
    /// - Parameters:
    ///   - endpoint: The API endpoint to call
    ///   - body: Optional request body (Encodable)
    ///   - queryItems: Optional query parameters
    func requestVoid(
        _ endpoint: APIEndpoint,
        body: (some Encodable)? = nil as Empty?,
        queryItems: [URLQueryItem]? = nil
    ) async throws {
        let config = FeaturePulse.shared

        guard !config.apiKey.isEmpty else {
            throw FeaturePulseError.missingAPIKey
        }

        guard let url = endpoint.url(baseURL: config.baseURL, queryItems: queryItems) else {
            throw FeaturePulseError.invalidURL
        }

        var request = buildRequest(url: url, method: endpoint.method, apiKey: config.apiKey)

        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        try validateResponse(response, data: data)
    }

    // MARK: - Private Helpers

    private func buildRequest(url: URL, method: HTTPMethod, apiKey: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        return request
    }

    private func validateResponse(_ response: URLResponse, data _: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeaturePulseError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200 ... 299:
            return
        case 403:
            throw FeaturePulseError.paymentRequired
        case 409:
            throw FeaturePulseError.alreadyVoted
        default:
            throw FeaturePulseError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - Empty Type for Requests Without Body

/// Placeholder type for requests without a body
struct Empty: Encodable {}
