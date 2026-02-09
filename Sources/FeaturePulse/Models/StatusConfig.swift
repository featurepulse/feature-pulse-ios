import Foundation

/// Configuration for a single status appearance
public struct StatusAppearance: Codable, Hashable, Sendable {
    /// Hex color string (e.g., "#EAB308")
    public let color: String
    /// SF Symbol name (e.g., "hourglass.circle.fill")
    public let icon: String
}

/// Maps status strings to their visual configuration (color + icon)
public typealias StatusConfig = [String: StatusAppearance]
