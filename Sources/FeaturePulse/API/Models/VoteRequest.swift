import Foundation

struct VoteRequest: Encodable {
    let deviceID: String
    let paymentType: String?
    let monthlyValueCents: Int?

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case paymentType = "payment_type"
        case monthlyValueCents = "monthly_value_cents"
    }
}
