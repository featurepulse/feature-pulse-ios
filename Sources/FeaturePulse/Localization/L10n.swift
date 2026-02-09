import SwiftUI

public extension FeaturePulse {
    enum L10n {
        // MARK: - Feature Requests

        public static var featureRequests: String {
            String(localized: "feature.requests", defaultValue: "Feature Requests", bundle: .module)
        }

        public static var newFeatureRequest: String {
            String(localized: "new.feature.request", defaultValue: "New Feature Request", bundle: .module)
        }

        // MARK: - Form Fields

        public static var title: String {
            String(localized: "title", defaultValue: "Title", bundle: .module)
        }

        public static var titlePlaceholder: String {
            String(
                localized: "title.placeholder", defaultValue: "What feature would you like to see?",
                bundle: .module
            )
        }

        public static var description: String {
            String(localized: "description", defaultValue: "Description", bundle: .module)
        }

        public static var descriptionPlaceholder: String {
            String(
                localized: "description.placeholder",
                defaultValue: "Describe your feature idea in detail...",
                bundle: .module
            )
        }

        public static var emailOptional: String {
            String(localized: "email.optional", defaultValue: "Email (optional)", bundle: .module)
        }

        // MARK: - Actions

        public static var submit: String {
            String(localized: "submit", defaultValue: "Submit", bundle: .module)
        }

        public static var cancel: String {
            String(localized: "cancel", defaultValue: "Cancel", bundle: .module)
        }

        // MARK: - Status

        public enum Status {
            public static var pending: String {
                String(localized: "status.pending", defaultValue: "Pending", bundle: .module)
            }

            public static var approved: String {
                String(localized: "status.approved", defaultValue: "Approved", bundle: .module)
            }

            public static var planned: String {
                String(localized: "status.planned", defaultValue: "Planned", bundle: .module)
            }

            public static var inProgress: String {
                String(localized: "status.in_progress", defaultValue: "In Progress", bundle: .module)
            }

            public static var completed: String {
                String(localized: "status.completed", defaultValue: "Completed", bundle: .module)
            }

            public static var rejected: String {
                String(localized: "status.rejected", defaultValue: "Rejected", bundle: .module)
            }
        }

        // MARK: - Messages

        public static var loadingError: String {
            String(
                localized: "loading.error", defaultValue: "Failed to load feature requests", bundle: .module
            )
        }

        public static var error: String {
            String(localized: "error", defaultValue: "Error", bundle: .module)
        }

        public static var ok: String {
            String(localized: "ok", defaultValue: "OK", bundle: .module)
        }

        public static var thankYou: String {
            String(localized: "thank.you", defaultValue: "Thanks for your feedback!", bundle: .module)
        }

        public static var invalidEmail: String {
            String(
                localized: "invalid.email", defaultValue: "Please enter a valid email address",
                bundle: .module
            )
        }

        // MARK: - Validation

        public static var titleTooShort: String {
            String(
                localized: "validation.title.too_short",
                defaultValue: "Title must be at least 3 characters",
                bundle: .module
            )
        }

        public static var titleTooLong: String {
            String(
                localized: "validation.title.too_long",
                defaultValue: "Title must not exceed 50 characters",
                bundle: .module
            )
        }

        public static var descriptionTooShort: String {
            String(
                localized: "validation.description.too_short",
                defaultValue: "Description must be at least 10 characters",
                bundle: .module
            )
        }

        public static var descriptionTooLong: String {
            String(
                localized: "validation.description.too_long",
                defaultValue: "Description must not exceed 500 characters",
                bundle: .module
            )
        }

        // MARK: - CTA

        public static var ctaMessage: String {
            String(
                localized: "cta.message",
                defaultValue: "Didn't find the feature you want?",
                bundle: .module
            )
        }

        public static var requestFeature: String {
            String(localized: "cta.request_feature", defaultValue: "Request a Feature", bundle: .module)
        }

        public static var ctaBannerMessage: String {
            String(
                localized: "cta.banner.message",
                defaultValue: "Let us know what features you'd like to see",
                bundle: .module
            )
        }

        // MARK: - Section Headers

        public static var titleHeader: String {
            String(localized: "section.title", defaultValue: "Title", bundle: .module)
        }

        public static var descriptionHeader: String {
            String(localized: "section.description", defaultValue: "Description", bundle: .module)
        }

        public static var contactHeader: String {
            String(localized: "section.contact", defaultValue: "Contact", bundle: .module)
        }

        public static var optional: String {
            String(localized: "optional", defaultValue: "Optional", bundle: .module)
        }

        // MARK: - Empty State

        public static var emptyStateTitle: String {
            String(localized: "empty.state.title", defaultValue: "No Feature Requests Yet", bundle: .module)
        }

        public static var emptyStateMessage: String {
            String(
                localized: "empty.state.message",
                defaultValue: "Be the first to share your ideas!\nLet us know what features you'd like to see.",
                bundle: .module
            )
        }

        // MARK: - Restrictions

        public static var restrictionAlertTitle: String {
            String(localized: "restriction.alert.title", defaultValue: "Subscription Required", bundle: .module)
        }

        public static func restrictionMessage(subscriptionName: String = "Pro") -> String {
            String(localized: "restriction.message", defaultValue: "Only \(subscriptionName) users can add new feature requests, but you can vote for already added requests.", bundle: .module)
        }

        // MARK: - Translation

        public static var translateAll: String {
            String(localized: "Translate All", defaultValue: "Translate All", bundle: .module)
        }

        public static var showOriginal: String {
            String(localized: "Show Original", defaultValue: "Show Original", bundle: .module)
        }

        // MARK: - Branding

        public static var poweredBy: String {
            String(localized: "powered.by", defaultValue: "Powered by", bundle: .module)
        }
    }
}

typealias L10n = FeaturePulse.L10n
