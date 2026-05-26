import SwiftUI

struct Backport<Content: View> {
    let content: Content
}

enum BackportContentTransition {
    case numericText(value: Double?)

    static func numericText() -> BackportContentTransition {
        .numericText(value: nil)
    }
}

enum BackportSymbolEffect {
    case bounce
    case pulse
}

struct BackportAnimation {
    private enum Kind {
        case smooth(duration: TimeInterval?)
        case bouncy(duration: TimeInterval?)
    }

    private let kind: Kind

    static let smooth = BackportAnimation(kind: .smooth(duration: nil))

    static func smooth(duration: TimeInterval? = nil) -> BackportAnimation {
        BackportAnimation(kind: .smooth(duration: duration))
    }

    static let bouncy = BackportAnimation(kind: .bouncy(duration: nil))

    static func bouncy(duration: TimeInterval? = nil) -> BackportAnimation {
        BackportAnimation(kind: .bouncy(duration: duration))
    }

    var animation: Animation {
        switch kind {
        case let .smooth(duration):
            if #available(iOS 17.0, macOS 14.0, *) {
                if let duration {
                    return .smooth(duration: duration)
                }
                return .smooth
            }
            return duration.map(Animation.easeInOut(duration:)) ?? .easeInOut
        case let .bouncy(duration):
            if #available(iOS 17.0, macOS 14.0, *) {
                if let duration {
                    return .bouncy(duration: duration)
                }
                return .bouncy
            }
            return .spring(response: duration ?? 0.5, dampingFraction: 0.7)
        }
    }
}

func withBackportAnimation<Result>(_ animation: BackportAnimation, _ body: () throws -> Result) rethrows -> Result {
    try withAnimation(animation.animation, body)
}

struct BackportContentUnavailableView: View {
    let title: String
    let systemImage: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        _ title: String,
        systemImage: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            ContentUnavailableView {
                Label(title, systemImage: systemImage)
            } description: {
                Text(description)
            } actions: {
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(.borderedProminent)
                }
            }
        } else {
            VStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
        }
    }
}

extension View {
    var backport: Backport<Self> {
        Backport(content: self)
    }
}

extension Backport {
    @ViewBuilder
    func contentTransition(_ transition: BackportContentTransition) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            switch transition {
            case let .numericText(value):
                if let value {
                    content.contentTransition(.numericText(value: value))
                } else {
                    content.contentTransition(.numericText())
                }
            }
        } else {
            content
        }
    }

    @ViewBuilder
    func symbolEffect(_ effect: BackportSymbolEffect) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            switch effect {
            case .bounce:
                content
            case .pulse:
                content.symbolEffect(.pulse)
            }
        } else {
            content
        }
    }

    @ViewBuilder
    func symbolEffect(_ effect: BackportSymbolEffect, value: some Equatable) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            switch effect {
            case .bounce:
                content.symbolEffect(.bounce, value: value)
            case .pulse:
                content.symbolEffect(.pulse, value: value)
            }
        } else {
            content
        }
    }

    @ViewBuilder
    func scrollTransition() -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            content.scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.2)
                    .scaleEffect(phase.isIdentity ? 1 : 0.9)
                    .blur(radius: phase.isIdentity ? 0 : 10)
            }
        } else {
            content
        }
    }

    func animation(_ animation: BackportAnimation, value: some Equatable) -> some View {
        content.animation(animation.animation, value: value)
    }
}
