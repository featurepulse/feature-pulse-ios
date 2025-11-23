import SwiftUI

/// Status of a feature request
public enum FeatureRequestStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case approved
    case inProgress = "in_progress"
    case completed
    case rejected

    /// Localized string for the status
    public var localizedString: String {
        switch self {
        case .pending: return L10n.Status.pending
        case .approved: return L10n.Status.approved
        case .inProgress: return L10n.Status.inProgress
        case .completed: return L10n.Status.completed
        case .rejected: return L10n.Status.rejected
        }
    }

    /// Color associated with the status
    public var color: Color {
        switch self {
        case .pending: return .yellow
        case .approved: return .blue
        case .inProgress: return .purple
        case .completed: return .green
        case .rejected: return .red
        }
    }

    /// SF Symbol icon for the status
    public var systemImage: String {
        switch self {
        case .pending: return "clock.fill"
        case .approved: return "checkmark.seal.fill"
        case .inProgress: return "eye.fill"
        case .completed: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        }
    }
}
