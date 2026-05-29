import SwiftUI

extension FeaturePulse.L10n {
    static func text(
        _ keyPath: KeyPath<FeaturePulse.Localization, LocalizedStringResource?>,
        key: StaticString,
        defaultValue: String.LocalizationValue
    ) -> String {
        if let override = FeaturePulse.shared.localization[keyPath: keyPath] {
            return String(localized: override)
        }

        return String(
            localized: key,
            defaultValue: defaultValue,
            bundle: .module
        )
    }
}
