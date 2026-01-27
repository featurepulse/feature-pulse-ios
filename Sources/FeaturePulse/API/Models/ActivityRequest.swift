import Foundation

struct ActivityRequest: Encodable {
    let userIdentifier: String
    let activityType: String

    enum CodingKeys: String, CodingKey {
        case userIdentifier = "user_identifier"
        case activityType = "activity_type"
    }
}
