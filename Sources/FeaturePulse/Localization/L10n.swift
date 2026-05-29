import SwiftUI

public extension FeaturePulse {
    enum L10n {
        // MARK: - Feature Requests
        public static var featureRequests: String {
            text(\.featureRequests, key: "feature.requests", defaultValue: "Feature Requests")
        }

        public static var newFeatureRequest: String {
            text(\.newFeatureRequest, key: "new.feature.request", defaultValue: "New Feature Request")
        }

        // MARK: - Form Fields
        public static var title: String {
            text(\.title, key: "title", defaultValue: "Title")
        }

        public static var titlePlaceholder: String {
            text(\.titlePlaceholder, key: "title.placeholder", defaultValue: "What feature would you like to see?")
        }

        public static var description: String {
            text(\.description, key: "description", defaultValue: "Description")
        }

        public static var descriptionPlaceholder: String {
            text(\.descriptionPlaceholder, key: "description.placeholder",
                 defaultValue: "Describe your feature idea in detail...")
        }

        public static var emailOptional: String {
            text(\.emailOptional, key: "email.optional", defaultValue: "Email (optional)")
        }

        // MARK: - Actions
        public static var submit: String {
            text(\.submit, key: "submit", defaultValue: "Submit")
        }

        public static var cancel: String {
            text(\.cancel, key: "cancel", defaultValue: "Cancel")
        }

        public static var retry: String {
            text(\.retry, key: "retry", defaultValue: "Retry")
        }

        // MARK: - Status
        public enum Status {
            public static var pending: String {
                text(\.statusPending, key: "status.pending", defaultValue: "Pending")
            }

            public static var approved: String {
                text(\.statusApproved, key: "status.approved", defaultValue: "Approved")
            }

            public static var planned: String {
                text(\.statusPlanned, key: "status.planned", defaultValue: "Planned")
            }

            public static var inProgress: String {
                text(\.statusInProgress, key: "status.inProgress", defaultValue: "In Progress")
            }

            public static var completed: String {
                text(\.statusCompleted, key: "status.completed", defaultValue: "Completed")
            }

            public static var rejected: String {
                text(\.statusRejected, key: "status.rejected", defaultValue: "Rejected")
            }
        }

        // MARK: - Messages
        public static var loadingError: String {
            text(\.loadingError, key: "loading.error", defaultValue: "Failed to load feature requests")
        }

        public static var error: String {
            text(\.error, key: "error", defaultValue: "Error")
        }

        public static var ok: String {
            text(\.ok, key: "ok", defaultValue: "OK")
        }

        public static var thankYou: String {
            text(\.thankYou, key: "thank.you", defaultValue: "Thanks for your feedback!")
        }

        public static var invalidEmail: String {
            text(\.invalidEmail, key: "invalid.email", defaultValue: "Please enter a valid email address")
        }

        // MARK: - Validation
        public static var titleTooShort: String {
            text(\.titleTooShort, key: "validation.title.tooShort", defaultValue: "Title must be at least 3 characters")
        }

        public static var titleTooLong: String {
            text(\.titleTooLong, key: "validation.title.tooLong", defaultValue: "Title must not exceed 50 characters")
        }

        public static var descriptionTooShort: String {
            text(\.descriptionTooShort, key: "validation.description.tooShort",
                 defaultValue: "Description must be at least 10 characters")
        }

        public static var descriptionTooLong: String {
            text(\.descriptionTooLong, key: "validation.description.tooLong",
                 defaultValue: "Description must not exceed 500 characters")
        }

        // MARK: - CTA
        public static var ctaMessage: String {
            text(\.ctaMessage, key: "cta.message", defaultValue: "Didn't find the feature you want?")
        }

        public static var requestFeature: String {
            text(\.requestFeature, key: "cta.requestFeature", defaultValue: "Request a Feature")
        }

        public static var ctaBannerMessage: String {
            text(\.ctaBannerMessage, key: "cta.banner.message",
                 defaultValue: "Let us know what features you'd like to see")
        }

        // MARK: - Section Headers
        public static var titleHeader: String {
            text(\.titleHeader, key: "section.title", defaultValue: "Title")
        }

        public static var descriptionHeader: String {
            text(\.descriptionHeader, key: "section.description", defaultValue: "Description")
        }

        public static var contactHeader: String {
            text(\.contactHeader, key: "section.contact", defaultValue: "Contact")
        }

        public static var optional: String {
            text(\.optional, key: "optional", defaultValue: "Optional")
        }

        // MARK: - Empty State
        public static var emptyStateTitle: String {
            text(\.emptyStateTitle, key: "empty.state.title", defaultValue: "No Feature Requests Yet")
        }

        public static var emptyStateMessage: String {
            text(
                \.emptyStateMessage,
                key: "empty.state.message",
                defaultValue: "Be the first to share your ideas!\nLet us know what features you'd like to see."
            )
        }

        public static var emptyStateCompletedTitle: String {
            text(\.emptyStateCompletedTitle, key: "empty.state.completed.title",
                 defaultValue: "No Completed Features Yet")
        }

        public static var emptyStateCompletedMessage: String {
            text(\.emptyStateCompletedMessage, key: "empty.state.completed.message",
                 defaultValue: "Completed features will appear here.")
        }

        // MARK: - Restrictions
        public static var restrictionAlertTitle: String {
            text(\.restrictionAlertTitle, key: "restriction.alert.title", defaultValue: "Subscription Required")
        }

        public static func restrictionMessage(subscriptionName: String = "Pro") -> String {
            text(
                \.restrictionMessage,
                key: "restriction.message",
                // swiftlint:disable:next line_length
                defaultValue: "Only {subscriptionName} users can add new feature requests, but you can vote for already added requests."
            )
            .replacingOccurrences(of: "{subscriptionName}", with: subscriptionName)
        }

        // MARK: - Translation
        public static var translateAll: String {
            text(\.translateAll, key: "Translate All", defaultValue: "Translate All")
        }

        public static var showOriginal: String {
            text(\.showOriginal, key: "Show Original", defaultValue: "Show Original")
        }

        // MARK: - Branding
        public static var poweredBy: String {
            text(\.poweredBy, key: "powered.by", defaultValue: "Powered by")
        }

        // MARK: - Tabs
        public static var tabRequests: String {
            text(\.tabRequests, key: "tab.requests", defaultValue: "Requests")
        }

        public static var tabCompleted: String {
            text(\.tabCompleted, key: "tab.completed", defaultValue: "Completed")
        }

        // MARK: - Sort
        public static var sortTop: String {
            text(\.sortTop, key: "sort.top", defaultValue: "Top")
        }

        public static var sortNewest: String {
            text(\.sortNewest, key: "sort.newest", defaultValue: "Newest")
        }

        public static var sort: String {
            text(\.sort, key: "sort", defaultValue: "Sort")
        }

        public static var sortReset: String {
            text(\.sortReset, key: "sort.reset", defaultValue: "Reset sorting")
        }
    }
}

typealias L10n = FeaturePulse.L10n
