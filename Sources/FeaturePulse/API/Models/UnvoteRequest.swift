import Foundation

struct UnvoteRequest: Encodable {
    let deviceID: String
    let customID: String?

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case customID = "custom_id"
    }
}
