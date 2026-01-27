import Foundation

struct SubmitFeatureRequest: Encodable {
    let title: String
    let description: String
    let deviceInfo: DeviceInfo
    let paymentType: String?
    let monthlyValueCents: Int?
    let originalAmountCents: Int?
    let currency: String?

    enum CodingKeys: String, CodingKey {
        case title, description, currency
        case deviceInfo = "device_info"
        case paymentType = "payment_type"
        case monthlyValueCents = "monthly_value_cents"
        case originalAmountCents = "original_amount_cents"
    }
}
