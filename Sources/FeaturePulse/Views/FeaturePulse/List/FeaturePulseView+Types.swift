import Foundation

extension FeaturePulseView {
    enum FeatureTab: CaseIterable {
        case requests, completed

        var label: String {
            switch self {
            case .requests: L10n.tabRequests
            case .completed: L10n.tabCompleted
            }
        }

        var systemImage: String {
            switch self {
            case .requests: "list.bullet"
            case .completed: "checkmark.circle.fill"
            }
        }

        func filter(_ requests: [FeatureRequest]) -> [FeatureRequest] {
            switch self {
            case .requests:
                requests.filter { $0.status != .completed && $0.status != .rejected }
            case .completed:
                requests.filter { $0.status == .completed }
            }
        }
    }

    enum SortOption: CaseIterable {
        case top, newest

        var label: String {
            switch self {
            case .top: L10n.sortTop
            case .newest: L10n.sortNewest
            }
        }

        var systemImage: String {
            switch self {
            case .top: "arrow.up"
            case .newest: "clock"
            }
        }

        func sort(_ requests: [FeatureRequest]) -> [FeatureRequest] {
            switch self {
            case .top:
                requests.sorted {
                    $0.voteCount != $1.voteCount
                        ? $0.voteCount > $1.voteCount
                        : ($0.createdAt ?? "") > ($1.createdAt ?? "")
                }
            case .newest:
                requests.sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
            }
        }
    }
}
