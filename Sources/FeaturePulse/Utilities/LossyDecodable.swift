import Foundation

/// Protocol for providing default values when decoding fails
public protocol DefaultValueProvider {
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

/// Provides the first case of a CaseIterable enum as default
public struct FirstCase<T: Codable & CaseIterable>: DefaultValueProvider, Sendable where T: RawRepresentable, T.RawValue == String, T: Sendable {
    public static var defaultValue: T {
        T.allCases.first!
    }
}

/// Property wrapper that provides a default value when decoding fails
@propertyWrapper
public struct Default<Provider: DefaultValueProvider>: Codable, Equatable, Hashable, Sendable where Provider.Value: Equatable & Hashable & Sendable, Provider: Sendable {
    public var wrappedValue: Provider.Value

    public init(wrappedValue: Provider.Value) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Try to decode the value, fall back to default if it fails
        if let value = try? container.decode(Provider.Value.self) {
            wrappedValue = value
        } else {
            wrappedValue = Provider.defaultValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }

    public static func == (lhs: Default<Provider>, rhs: Default<Provider>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
