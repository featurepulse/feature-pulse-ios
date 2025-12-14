import Foundation

public extension FeaturePulse {
    struct Payment: Codable, Equatable, Sendable {
        /// Monthly recurring revenue in cents
        let monthlyValueInCents: Int

        /// Original payment type for analytics
        let paymentType: PaymentType

        /// Original amount in the payment's currency
        let originalAmount: Decimal

        /// Currency code (ISO 4217) - e.g., "USD", "EUR", "GBP"
        let currency: String

        // MARK: - Payment Types

        public enum PaymentType: String, Codable, Sendable {
            case free
            case weekly
            case monthly
            case yearly
            case lifetime
        }

        // MARK: - Free

        /// Free tier user
        public static var free: Payment {
            Payment(
                monthlyValueInCents: 0,
                paymentType: .free,
                originalAmount: 0,
                currency: "USD"
            )
        }

        // MARK: - Weekly

        /// Accepts a price expressed in `Decimal` e.g: 2.99 or 11.49
        /// Calculates MRR using accurate weekly-to-monthly conversion (52 weeks / 12 months = 4.333...)
        /// - Parameters:
        ///   - amount: The payment amount
        ///   - currency: ISO 4217 currency code (e.g., "USD", "EUR", "GBP")
        public static func weekly(_ amount: Decimal, currency: String) -> Payment {
            let amountInCents = NSDecimalNumber(decimal: amount * 100).intValue
            let monthlyValue = NSDecimalNumber(decimal: Decimal(amountInCents) * 4)
                .rounding(accordingToBehavior: RoundUp())
                .intValue

            return Payment(
                monthlyValueInCents: monthlyValue,
                paymentType: .weekly,
                originalAmount: amount,
                currency: currency
            )
        }

        // MARK: - Monthly

        /// Accepts a price expressed in `Decimal` e.g: 6.99 or 19.49
        /// - Parameters:
        ///   - amount: The payment amount
        ///   - currency: ISO 4217 currency code (e.g., "USD", "EUR", "GBP")
        public static func monthly(_ amount: Decimal, currency: String) -> Payment {
            let amountInCents = NSDecimalNumber(decimal: amount * 100).intValue

            return Payment(
                monthlyValueInCents: amountInCents,
                paymentType: .monthly,
                originalAmount: amount,
                currency: currency
            )
        }

        // MARK: - Yearly

        /// Accepts a price expressed in `Decimal` e.g: 69.99 or 199.49
        /// - Parameters:
        ///   - amount: The payment amount
        ///   - currency: ISO 4217 currency code (e.g., "USD", "EUR", "GBP")
        public static func yearly(_ amount: Decimal, currency: String) -> Payment {
            let monthlyValue = NSDecimalNumber(decimal: (amount * 100) / 12)
                .rounding(accordingToBehavior: RoundUp())
                .intValue

            return Payment(
                monthlyValueInCents: monthlyValue,
                paymentType: .yearly,
                originalAmount: amount,
                currency: currency
            )
        }

        // MARK: - Lifetime

        /// Accepts a price expressed in `Decimal` e.g: 99.99 or 299.99
        /// Amortizes over expected lifetime (default 24 months)
        /// - Parameters:
        ///   - amount: The one-time payment amount
        ///   - currency: ISO 4217 currency code (e.g., "USD", "EUR", "GBP")
        ///   - expectedLifetimeMonths: Number of months to amortize over (default: 24)
        public static func lifetime(_ amount: Decimal, currency: String, expectedLifetimeMonths: Int = 24) -> Payment {
            let monthlyValue = NSDecimalNumber(decimal: (amount * 100) / Decimal(expectedLifetimeMonths))
                .rounding(accordingToBehavior: RoundUp())
                .intValue

            return Payment(
                monthlyValueInCents: monthlyValue,
                paymentType: .lifetime,
                originalAmount: amount,
                currency: currency
            )
        }

        // MARK: - Computed Properties

        /// MRR in dollars (for display)
        public var monthlyValue: Decimal {
            Decimal(monthlyValueInCents) / 100
        }

        /// Annual recurring revenue in cents
        public var annualValueInCents: Int {
            monthlyValueInCents * 12
        }

        /// Annual recurring revenue in dollars
        public var annualValue: Decimal {
            Decimal(annualValueInCents) / 100
        }

        /// Returns true if this is a paying customer
        public var isPaying: Bool {
            monthlyValueInCents > 0
        }
    }
}

typealias Payment = FeaturePulse.Payment

// MARK: - RoundUp Helper

private class RoundUp: NSObject, NSDecimalNumberBehaviors {
    func roundingMode() -> NSDecimalNumber.RoundingMode {
        .up
    }

    func scale() -> Int16 {
        0
    }

    func exceptionDuringOperation(
        _: Selector,
        error _: NSDecimalNumber.CalculationError,
        leftOperand _: NSDecimalNumber,
        rightOperand _: NSDecimalNumber?
    ) -> NSDecimalNumber? {
        // We don't provide custom exception handling; return nil to let the system handle it.
        nil
    }
}
