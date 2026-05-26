// swiftlint:disable identifier_name
@testable import FeaturePulse
import Foundation
import Testing

@Suite(.tags(.api))
struct APIEndpointTests {
    @Test
    func `endpoint methods`() {
        #expect(APIEndpoint.featureRequests.method == .get)
        #expect(APIEndpoint.activity.method == .post)
        #expect(APIEndpoint.submitFeatureRequest.method == .post)
        #expect(APIEndpoint.vote(featureRequestID: "request-1").method == .post)
        #expect(APIEndpoint.unvote(featureRequestID: "request-1").method == .delete)
        #expect(APIEndpoint.syncUser.method == .post)
    }

    @Test
    func `endpoint paths`() {
        #expect(APIEndpoint.activity.path == "/api/sdk/activity")
        #expect(APIEndpoint.featureRequests.path == "/api/sdk/feature-requests")
        #expect(APIEndpoint.submitFeatureRequest.path == "/api/sdk/feature-requests")
        #expect(APIEndpoint.vote(featureRequestID: "request-1").path == "/api/sdk/feature-requests/request-1/vote")
        #expect(APIEndpoint.unvote(featureRequestID: "request-1").path == "/api/sdk/feature-requests/request-1/vote")
        #expect(APIEndpoint.syncUser.path == "/api/sdk/user")
    }

    @Test
    func `endpoint URL includes query items`() throws {
        let url = try #require(APIEndpoint.featureRequests.url(
            baseURL: "https://example.com",
            queryItems: [
                URLQueryItem(name: "device_id", value: "device 1"),
                URLQueryItem(name: "limit", value: "20")
            ]
        ))

        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))

        #expect(components.scheme == "https")
        #expect(components.host == "example.com")
        #expect(components.path == "/api/sdk/feature-requests")
        #expect(components.queryItems?.first(where: { $0.name == "device_id" })?.value == "device 1")
        #expect(components.queryItems?.first(where: { $0.name == "limit" })?.value == "20")
    }
}

// swiftlint:enable identifier_name
