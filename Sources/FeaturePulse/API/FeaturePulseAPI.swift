import Foundation

/// API client for communicating with FeaturePulse backend
public final class FeaturePulseAPI: Sendable {
    public static let shared = FeaturePulseAPI()

    private let client = NetworkClient.shared

    private init() {}

    // MARK: - Activity Tracking
    /// Tracks user activity (app opens) for engagement metrics
    /// - Parameter type: The type of activity to track (default: "app_open")
    public func trackActivity(type: String = "app_open") async throws {
        let config = FeaturePulse.shared

        let request = ActivityRequest(
            userIdentifier: config.user.deviceID,
            activityType: type
        )

        let _: ActivityResponse = try await client.request(.activity, body: request)
    }

    // MARK: - Feature Requests
    /// Fetches all feature requests for the configured project
    /// - Returns: Array of feature requests
    public func fetchFeatureRequests() async throws -> [FeatureRequest] {
        let config = FeaturePulse.shared

        let queryItems = [
            URLQueryItem(name: "device_id", value: config.user.deviceID)
        ]

        let response: FeatureRequestsResponse = try await client.request(
            .featureRequests,
            queryItems: queryItems
        )

        // Update configuration with settings from server
        applyServerSettings(from: response)

        return response.data
    }

    /// Submits a new feature request
    /// - Parameters:
    ///   - title: Title of the feature request
    ///   - description: Detailed description
    public func submitFeatureRequest(title: String, description: String) async throws {
        let config = FeaturePulse.shared

        let deviceInfo = DeviceInfo(
            deviceID: config.user.deviceID,
            bundleID: Bundle.main.bundleIdentifier ?? "unknown"
        )

        let request = SubmitFeatureRequest(
            title: title,
            description: description,
            deviceInfo: deviceInfo,
            paymentType: config.user.payment?.paymentType.rawValue,
            monthlyValueCents: config.user.payment?.monthlyValueInCents,
            originalAmountCents: config.user.payment.map {
                NSDecimalNumber(decimal: $0.originalAmount * 100).intValue
            },
            currency: config.user.payment?.currency
        )

        try await client.requestVoid(.submitFeatureRequest, body: request)
    }

    // MARK: - Voting
    /// Votes for a feature request
    /// - Parameter id: The feature request ID to vote for
    public func voteForFeatureRequest(id: String) async throws {
        let config = FeaturePulse.shared

        let request = VoteRequest(
            deviceID: config.user.deviceID,
            paymentType: config.user.payment?.paymentType.rawValue,
            monthlyValueCents: config.user.payment?.monthlyValueInCents
        )

        try await client.requestVoid(.vote(featureRequestID: id), body: request)
    }

    /// Removes vote from a feature request
    /// - Parameter id: The feature request ID to unvote
    public func unvoteForFeatureRequest(id: String) async throws {
        let config = FeaturePulse.shared

        let request = UnvoteRequest(deviceID: config.user.deviceID)

        try await client.requestVoid(.unvote(featureRequestID: id), body: request)
    }

    // MARK: - User Management
    /// Syncs user information including payment data to the backend
    public func syncUser() async throws {
        let config = FeaturePulse.shared

        let request = SyncUserRequest(
            userIdentifier: config.user.userIdentifier,
            customID: config.user.customID,
            paymentType: config.user.payment?.paymentType.rawValue,
            monthlyValueCents: config.user.payment?.monthlyValueInCents,
            originalAmountCents: config.user.payment.map {
                NSDecimalNumber(decimal: $0.originalAmount * 100).intValue
            },
            currency: config.user.payment?.currency
        )

        try await client.requestVoid(.syncUser, body: request)
    }

    private func applyServerSettings(from response: FeatureRequestsResponse) {
        let config = FeaturePulse.shared

        if let showStatus = response.showStatus {
            config.showStatus = showStatus
        }

        if let showTranslation = response.showTranslation {
            config.showTranslation = showTranslation
        }

        if let showWatermark = response.showWatermark {
            config.showWatermark = showWatermark
        }

        if let permissions = response.permissions {
            config.permissions = permissions
        }
    }
}
