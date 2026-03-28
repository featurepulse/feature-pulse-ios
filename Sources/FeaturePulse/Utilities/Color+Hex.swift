import SwiftUI

extension Color {
    /// Initialize a Color from a hex string (e.g., "#EAB308" or "EAB308")
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        guard hexSanitized.count == 6,
              let rgb = UInt64(hexSanitized, radix: 16)
        else {
            return nil
        }

        // swiftlint:disable:next identifier_name
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        // swiftlint:disable:next identifier_name
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        // swiftlint:disable:next identifier_name
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
