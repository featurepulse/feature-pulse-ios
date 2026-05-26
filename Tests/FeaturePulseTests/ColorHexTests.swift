// swiftlint:disable identifier_name
@testable import FeaturePulse
import SwiftUI
import Testing

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

@Suite(.tags(.utilities))
struct ColorHexTests {
    @Test
    func `creates color from hash prefixed hex`() throws {
        let color = try #require(Color(hex: "#570DF8"))
        let components = try colorComponents(color)

        #expect(components.red == 87)
        #expect(components.green == 13)
        #expect(components.blue == 248)
    }

    @Test
    func `creates color from unprefixed hex with whitespace`() throws {
        let color = try #require(Color(hex: "  00FF7F\n"))
        let components = try colorComponents(color)

        #expect(components.red == 0)
        #expect(components.green == 255)
        #expect(components.blue == 127)
    }

    @Test
    func `rejects invalid hex`() {
        #expect(Color(hex: "#FFF") == nil)
        #expect(Color(hex: "#GGGGGG") == nil)
        #expect(Color(hex: "1234567") == nil)
    }

    private func colorComponents(_ color: Color) throws -> RGBComponents {
        #if os(macOS)
            let nativeColor = try #require(NSColor(color).usingColorSpace(.sRGB))
            return RGBComponents(
                red: Int((nativeColor.redComponent * 255).rounded()),
                green: Int((nativeColor.greenComponent * 255).rounded()),
                blue: Int((nativeColor.blueComponent * 255).rounded())
            )
        #else
            let nativeColor = UIColor(color)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0

            nativeColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

            return RGBComponents(
                red: Int((red * 255).rounded()),
                green: Int((green * 255).rounded()),
                blue: Int((blue * 255).rounded())
            )
        #endif
    }
}

private struct RGBComponents {
    let red: Int
    let green: Int
    let blue: Int
}

// swiftlint:enable identifier_name
