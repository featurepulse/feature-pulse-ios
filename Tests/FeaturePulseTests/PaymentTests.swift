// swiftlint:disable identifier_name
@testable import FeaturePulse
import Foundation
import Testing

@Suite(.tags(.payments))
struct PaymentTests {
    @Test
    func `free payment has no recurring value`() {
        let payment = FeaturePulse.Payment.free

        #expect(payment.paymentType == .free)
        #expect(payment.monthlyValueInCents == 0)
        #expect(payment.originalAmount == 0)
        #expect(payment.currency == "USD")
        #expect(!payment.isPaying)
    }

    @Test
    func `weekly payment uses monthly recurring approximation`() {
        let payment = FeaturePulse.Payment.weekly(2.99, currency: "EUR")

        #expect(payment.paymentType == .weekly)
        #expect(payment.monthlyValueInCents == 1196)
        #expect(payment.monthlyValue == 11.96)
        #expect(payment.annualValueInCents == 14352)
        #expect(payment.currency == "EUR")
        #expect(payment.isPaying)
    }

    @Test
    func `monthly payment uses amount as monthly value`() {
        let payment = FeaturePulse.Payment.monthly(9.99, currency: "USD")

        #expect(payment.paymentType == .monthly)
        #expect(payment.monthlyValueInCents == 999)
        #expect(payment.annualValue == 119.88)
    }

    @Test
    func `yearly payment rounds monthly value up`() {
        let payment = FeaturePulse.Payment.yearly(79.99, currency: "GBP")

        #expect(payment.paymentType == .yearly)
        #expect(payment.monthlyValueInCents == 667)
        #expect(payment.currency == "GBP")
    }

    @Test
    func `lifetime payment uses expected lifetime months`() {
        let payment = FeaturePulse.Payment.lifetime(199.99, currency: "USD", expectedLifetimeMonths: 36)

        #expect(payment.paymentType == .lifetime)
        #expect(payment.monthlyValueInCents == 556)
    }

    @Test
    func `payment codable round trip`() throws {
        let payment = FeaturePulse.Payment.monthly(14.99, currency: "CHF")
        let data = try JSONEncoder().encode(payment)
        let decoded = try JSONDecoder().decode(FeaturePulse.Payment.self, from: data)

        #expect(decoded == payment)
    }
}

// swiftlint:enable identifier_name
