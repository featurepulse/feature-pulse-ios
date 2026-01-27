import Foundation

struct DeviceInfo: Encodable {
    let deviceID: String
    let bundleID: String

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case bundleID = "bundle_id"
    }
}
