// swiftlint:disable identifier_name
@testable import FeaturePulse
import Foundation
import Testing

@Suite(.tags(.api))
struct APIModelEncodingTests {
    @Test
    func `activity request uses snake case keys`() throws {
        let request = ActivityRequest(userIdentifier: "device-1", activityType: "app_open")
        let json = try encodedJSONObject(request)

        #expect(json["user_identifier"] as? String == "device-1")
        #expect(json["activity_type"] as? String == "app_open")
    }

    @Test
    func `submit feature request uses expected payload shape`() throws {
        let request = SubmitFeatureRequest(
            title: "Calendar sync",
            description: "Sync events into the calendar.",
            deviceInfo: DeviceInfo(deviceID: "device-1", bundleID: "com.example.demo"),
            paymentType: "monthly",
            monthlyValueCents: 999,
            originalAmountCents: 999,
            currency: "USD"
        )

        let json = try encodedJSONObject(request)
        let deviceInfo = try #require(json["device_info"] as? [String: Any])

        #expect(json["title"] as? String == "Calendar sync")
        #expect(json["description"] as? String == "Sync events into the calendar.")
        #expect(json["payment_type"] as? String == "monthly")
        #expect(json["monthly_value_cents"] as? Int == 999)
        #expect(json["original_amount_cents"] as? Int == 999)
        #expect(json["currency"] as? String == "USD")
        #expect(deviceInfo["device_id"] as? String == "device-1")
        #expect(deviceInfo["bundle_id"] as? String == "com.example.demo")
    }

    @Test
    func `vote and unvote requests use device ID key`() throws {
        let voteRequest = VoteRequest(deviceID: "device-1", paymentType: "yearly", monthlyValueCents: 667)
        let vote = try encodedJSONObject(voteRequest)
        let unvote = try encodedJSONObject(UnvoteRequest(deviceID: "device-1"))

        #expect(vote["device_id"] as? String == "device-1")
        #expect(vote["payment_type"] as? String == "yearly")
        #expect(vote["monthly_value_cents"] as? Int == 667)
        #expect(unvote["device_id"] as? String == "device-1")
    }

    @Test
    func `feature requests response decodes server settings`() throws {
        let data = """
        {
          "success": true,
          "data": [],
          "show_status": true,
          "show_translation": false,
          "show_watermark": false,
          "permissions": {
            "can_create_feature_request": false
          },
          "status_config": {
            "planned": {
              "color": "#FF00AA",
              "icon": "calendar.badge.clock"
            }
          }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(FeatureRequestsResponse.self, from: data)

        #expect(response.success)
        #expect(response.data == [])
        #expect(response.showStatus == true)
        #expect(response.showTranslation == false)
        #expect(response.showWatermark == false)
        #expect(response.permissions == Permissions(canCreateFeatureRequest: false))
        #expect(response.statusConfig?["planned"]?.color == "#FF00AA")
        #expect(response.statusConfig?["planned"]?.icon == "calendar.badge.clock")
    }

    private func encodedJSONObject(_ value: some Encodable) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}

// swiftlint:enable identifier_name
