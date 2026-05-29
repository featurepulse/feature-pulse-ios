import SwiftUI

public extension FeaturePulse {
    struct Localization: Sendable, Equatable {
        public var featureRequests: LocalizedStringResource?
        public var newFeatureRequest: LocalizedStringResource?
        public var title: LocalizedStringResource?
        public var titlePlaceholder: LocalizedStringResource?
        public var description: LocalizedStringResource?
        public var descriptionPlaceholder: LocalizedStringResource?
        public var emailOptional: LocalizedStringResource?
        public var submit: LocalizedStringResource?
        public var cancel: LocalizedStringResource?
        public var retry: LocalizedStringResource?
        public var statusPending: LocalizedStringResource?
        public var statusApproved: LocalizedStringResource?
        public var statusPlanned: LocalizedStringResource?
        public var statusInProgress: LocalizedStringResource?
        public var statusCompleted: LocalizedStringResource?
        public var statusRejected: LocalizedStringResource?
        public var loadingError: LocalizedStringResource?
        public var error: LocalizedStringResource?
        public var ok: LocalizedStringResource?
        public var thankYou: LocalizedStringResource?
        public var invalidEmail: LocalizedStringResource?
        public var titleTooShort: LocalizedStringResource?
        public var titleTooLong: LocalizedStringResource?
        public var descriptionTooShort: LocalizedStringResource?
        public var descriptionTooLong: LocalizedStringResource?
        public var ctaMessage: LocalizedStringResource?
        public var requestFeature: LocalizedStringResource?
        public var ctaBannerMessage: LocalizedStringResource?
        public var titleHeader: LocalizedStringResource?
        public var descriptionHeader: LocalizedStringResource?
        public var contactHeader: LocalizedStringResource?
        public var optional: LocalizedStringResource?
        public var emptyStateTitle: LocalizedStringResource?
        public var emptyStateMessage: LocalizedStringResource?
        public var emptyStateCompletedTitle: LocalizedStringResource?
        public var emptyStateCompletedMessage: LocalizedStringResource?
        public var restrictionAlertTitle: LocalizedStringResource?
        public var restrictionMessage: LocalizedStringResource?
        public var translateAll: LocalizedStringResource?
        public var showOriginal: LocalizedStringResource?
        public var poweredBy: LocalizedStringResource?
        public var tabRequests: LocalizedStringResource?
        public var tabCompleted: LocalizedStringResource?
        public var sortTop: LocalizedStringResource?
        public var sortNewest: LocalizedStringResource?
        public var sort: LocalizedStringResource?
        public var sortReset: LocalizedStringResource?

        public init(
            featureRequests: LocalizedStringResource? = nil,
            newFeatureRequest: LocalizedStringResource? = nil,
            title: LocalizedStringResource? = nil,
            titlePlaceholder: LocalizedStringResource? = nil,
            description: LocalizedStringResource? = nil,
            descriptionPlaceholder: LocalizedStringResource? = nil,
            emailOptional: LocalizedStringResource? = nil,
            submit: LocalizedStringResource? = nil,
            cancel: LocalizedStringResource? = nil,
            retry: LocalizedStringResource? = nil,
            statusPending: LocalizedStringResource? = nil,
            statusApproved: LocalizedStringResource? = nil,
            statusPlanned: LocalizedStringResource? = nil,
            statusInProgress: LocalizedStringResource? = nil,
            statusCompleted: LocalizedStringResource? = nil,
            statusRejected: LocalizedStringResource? = nil,
            loadingError: LocalizedStringResource? = nil,
            error: LocalizedStringResource? = nil,
            ok: LocalizedStringResource? = nil,
            thankYou: LocalizedStringResource? = nil,
            invalidEmail: LocalizedStringResource? = nil,
            titleTooShort: LocalizedStringResource? = nil,
            titleTooLong: LocalizedStringResource? = nil,
            descriptionTooShort: LocalizedStringResource? = nil,
            descriptionTooLong: LocalizedStringResource? = nil,
            ctaMessage: LocalizedStringResource? = nil,
            requestFeature: LocalizedStringResource? = nil,
            ctaBannerMessage: LocalizedStringResource? = nil,
            titleHeader: LocalizedStringResource? = nil,
            descriptionHeader: LocalizedStringResource? = nil,
            contactHeader: LocalizedStringResource? = nil,
            optional: LocalizedStringResource? = nil,
            emptyStateTitle: LocalizedStringResource? = nil,
            emptyStateMessage: LocalizedStringResource? = nil,
            emptyStateCompletedTitle: LocalizedStringResource? = nil,
            emptyStateCompletedMessage: LocalizedStringResource? = nil,
            restrictionAlertTitle: LocalizedStringResource? = nil,
            restrictionMessage: LocalizedStringResource? = nil,
            translateAll: LocalizedStringResource? = nil,
            showOriginal: LocalizedStringResource? = nil,
            poweredBy: LocalizedStringResource? = nil,
            tabRequests: LocalizedStringResource? = nil,
            tabCompleted: LocalizedStringResource? = nil,
            sortTop: LocalizedStringResource? = nil,
            sortNewest: LocalizedStringResource? = nil,
            sort: LocalizedStringResource? = nil,
            sortReset: LocalizedStringResource? = nil
        ) {
            self.featureRequests = featureRequests
            self.newFeatureRequest = newFeatureRequest
            self.title = title
            self.titlePlaceholder = titlePlaceholder
            self.description = description
            self.descriptionPlaceholder = descriptionPlaceholder
            self.emailOptional = emailOptional
            self.submit = submit
            self.cancel = cancel
            self.retry = retry
            self.statusPending = statusPending
            self.statusApproved = statusApproved
            self.statusPlanned = statusPlanned
            self.statusInProgress = statusInProgress
            self.statusCompleted = statusCompleted
            self.statusRejected = statusRejected
            self.loadingError = loadingError
            self.error = error
            self.ok = ok
            self.thankYou = thankYou
            self.invalidEmail = invalidEmail
            self.titleTooShort = titleTooShort
            self.titleTooLong = titleTooLong
            self.descriptionTooShort = descriptionTooShort
            self.descriptionTooLong = descriptionTooLong
            self.ctaMessage = ctaMessage
            self.requestFeature = requestFeature
            self.ctaBannerMessage = ctaBannerMessage
            self.titleHeader = titleHeader
            self.descriptionHeader = descriptionHeader
            self.contactHeader = contactHeader
            self.optional = optional
            self.emptyStateTitle = emptyStateTitle
            self.emptyStateMessage = emptyStateMessage
            self.emptyStateCompletedTitle = emptyStateCompletedTitle
            self.emptyStateCompletedMessage = emptyStateCompletedMessage
            self.restrictionAlertTitle = restrictionAlertTitle
            self.restrictionMessage = restrictionMessage
            self.translateAll = translateAll
            self.showOriginal = showOriginal
            self.poweredBy = poweredBy
            self.tabRequests = tabRequests
            self.tabCompleted = tabCompleted
            self.sortTop = sortTop
            self.sortNewest = sortNewest
            self.sort = sort
            self.sortReset = sortReset
        }
    }
}
