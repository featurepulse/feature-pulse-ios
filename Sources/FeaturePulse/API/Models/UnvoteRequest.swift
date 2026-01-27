import Foundation

struct UnvoteRequest: Encodable {
    let deviceID: String

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
    }
}
