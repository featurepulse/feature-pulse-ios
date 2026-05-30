import SwiftUI

extension FeaturePulse.L10n {
    static func text(
        _ keyPath: KeyPath<FeaturePulse.Localization, LocalizedStringResource?>,
        key: String,
        defaultValue: String
    ) -> String {
        if let override = FeaturePulse.shared.localization[keyPath: keyPath] {
            return String(localized: override)
        }

        return Bundle.module.localizedString(forKey: key, value: defaultValue, table: nil)
    }
}
