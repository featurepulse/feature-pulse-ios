import Foundation

struct SyncUserRequest: Encodable {
    let userIdentifier: String
    let customID: String?
    let paymentType: String?
    let monthlyValueCents: Int?
    let originalAmountCents: Int?
    let currency: String?

    enum CodingKeys: String, CodingKey {
        case customID = "custom_id"
        case userIdentifier = "user_identifier"
        case paymentType = "payment_type"
        case monthlyValueCents = "monthly_value_cents"
        case originalAmountCents = "original_amount_cents"
        case currency
    }
}
