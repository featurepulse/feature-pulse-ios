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
        case .pending: L10n.Status.pending
        case .approved: L10n.Status.approved
        case .inProgress: L10n.Status.inProgress
        case .completed: L10n.Status.completed
        case .rejected: L10n.Status.rejected
        }
    }

    /// Color associated with the status
    public var color: Color {
        switch self {
        case .pending: .yellow
        case .approved: .blue
        case .inProgress: .purple
        case .completed: .green
        case .rejected: .red
        }
    }

    /// SF Symbol icon for the status
    public var systemImage: String {
        switch self {
        case .pending: "clock.fill"
        case .approved: "checkmark.seal.fill"
        case .inProgress: "eye.fill"
        case .completed: "checkmark.circle.fill"
        case .rejected: "xmark.circle.fill"
        }
    }
}
