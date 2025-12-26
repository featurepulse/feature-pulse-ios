import Foundation

#if canImport(RevenueCat)
import RevenueCat

public extension FeaturePulse {
    /// Update user payment information from RevenueCat CustomerInfo with Offerings
    ///
    /// This is the recommended approach as it gets accurate price and currency from StoreKit.
    ///
    /// # Example Usage:
    /// ```swift
    /// import RevenueCat
    ///
    /// // Get customer info and offerings
    /// let customerInfo = try await Purchases.shared.customerInfo()
    /// let offerings = try await Purchases.shared.offerings()
    ///
    /// // Update user payment info from RevenueCat
    /// FeaturePulse.shared.updateUserFromRevenueCat(
    ///     customerInfo: customerInfo,
    ///     offerings: offerings,
    ///     entitlementID: "pro"  // Your entitlement identifier
    /// )
    /// ```
    ///
    /// # Parameters:
    /// - customerInfo: RevenueCat CustomerInfo object
    /// - offerings: RevenueCat Offerings object (used to get accurate pricing)
    /// - entitlementID: The entitlement identifier to track (e.g., "pro", "premium")
    /// - expectedLifetimeMonths: Expected lifetime for lifetime purchases (default: 24 months)
    ///
    /// # How it Works:
    /// 1. Checks for active entitlements
    /// 2. Matches the entitlement's product ID to the current offering's packages
    /// 3. Gets accurate price and currency from StoreKit product
    /// 4. Uses packageType to determine subscription period
    /// 5. Syncs to FeaturePulse for MRR tracking
    func updateUserFromRevenueCat(
        customerInfo: CustomerInfo,
        offerings: Offerings,
        entitlementID: String,
        expectedLifetimeMonths: Int = 24
    ) {
        // Get the active entitlement
        guard let entitlement = customerInfo.entitlements[entitlementID],
            entitlement.isActive
        else {
            updateUser(payment: .free)
            return
        }

        // Get current offering
        guard let currentOffering = offerings.current else {
            updateUser(payment: .free)
            return
        }

        // Match the entitlement's product ID to a package
        let productId = entitlement.productIdentifier
        guard let matchedPackage = currentOffering.availablePackages.first(where: {
            $0.storeProduct.productIdentifier == productId
        }) else {
            updateUser(payment: .free)
            return
        }

        // Get accurate price and currency from StoreKit
        let price = matchedPackage.storeProduct.price
        let currency = matchedPackage.storeProduct.currencyCode ?? "USD"

        // Determine payment type from package type
        let payment: Payment = {
            switch matchedPackage.packageType {
            case .weekly:
                return .weekly(price, currency: currency)
            case .monthly:
                return .monthly(price, currency: currency)
            case .annual:
                return .yearly(price, currency: currency)
            case .lifetime:
                return .lifetime(price, currency: currency, expectedLifetimeMonths: expectedLifetimeMonths)
            default:
                return .free
            }
        }()

        updateUser(payment: payment)
    }
}

#endif
