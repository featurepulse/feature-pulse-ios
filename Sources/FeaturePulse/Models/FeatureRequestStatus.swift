import SwiftUI

/// Status of a feature request
public enum FeatureRequestStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case approved
    case planned
    case inProgress = "in_progress"
    case completed
    case rejected

    /// Localized string for the status
    public var localizedString: String {
        switch self {
        case .pending: L10n.Status.pending
        case .approved: L10n.Status.approved
        case .planned: L10n.Status.planned
        case .inProgress: L10n.Status.inProgress
        case .completed: L10n.Status.completed
        case .rejected: L10n.Status.rejected
        }
    }

    /// Color associated with the status — uses API config if available, else defaults
    public var color: Color {
        if let appearance = FeaturePulse.shared.statusConfig?[rawValue],
           let apiColor = Color(hex: appearance.color) {
            return apiColor
        }
        return switch self {
        case .pending: .yellow
        case .approved: .blue
        case .planned: .pink
        case .inProgress: .cyan
        case .completed: .green
        case .rejected: .red
        }
    }

    /// SF Symbol icon for the status — uses API config if available, else defaults
    public var systemImage: String {
        if let appearance = FeaturePulse.shared.statusConfig?[rawValue] {
            return appearance.icon
        }
        return switch self {
        case .pending: "hourglass.bottomhalf.filled"
        case .approved: "checkmark.seal.fill"
        case .planned: "calendar"
        case .inProgress: "clock.fill"
        case .completed: "checkmark.circle.fill"
        case .rejected: "xmark.circle.fill"
        }
    }
}
