// swiftlint:disable identifier_name
@testable import FeaturePulse
import Foundation
import Testing

@Suite(.tags(.api))
struct APIResponseTests {
    @Test
    func `generic response decodes data`() throws {
        let data = #"{"success":true,"data":"ok"}"#.data(using: .utf8)!

        let response = try JSONDecoder().decode(APIResponse<String>.self, from: data)

        #expect(response.success)
        #expect(response.data == "ok")
    }

    @Test
    func `empty response defaults to success`() {
        let response = EmptyResponse()

        #expect(response.success == true)
        #expect(response.message == nil)
    }

    @Test
    func `activity response decodes optional message`() throws {
        let data = #"{"success":true,"message":"tracked"}"#.data(using: .utf8)!

        let response = try JSONDecoder().decode(ActivityResponse.self, from: data)

        #expect(response.success)
        #expect(response.message == "tracked")
    }

    @Test
    func `feature requests response decodes duplicate suggestions setting`() throws {
        let data = """
        {
          "success": true,
          "data": [],
          "duplicate_suggestions_enabled": true
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(FeatureRequestsResponse.self, from: data)

        #expect(response.duplicateSuggestionsEnabled == true)
    }
}

// swiftlint:enable identifier_name
