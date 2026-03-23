import SwiftUI

extension Color {
    /// Adaptive background color (UIColor.systemBackground on iOS, NSColor.windowBackgroundColor on macOS)
    static var systemBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    /// Adaptive label color (UIColor.label on iOS, NSColor.labelColor on macOS)
    static var label: Color {
        #if os(iOS)
        Color(uiColor: .label)
        #else
        Color(nsColor: .labelColor)
        #endif
    }
}
