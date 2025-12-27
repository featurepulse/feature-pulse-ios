import SwiftUI
#if canImport(Translation)
    import Translation
#endif

/// Main view displaying list of feature requests
public struct FeaturePulseView: View {
    @State private var viewModel = FeaturePulseViewModel()
    @State private var showingNewRequest = false
    @State private var selectedRequest: FeatureRequest?
    @State private var restrictionAlert: RestrictionAlert?
    @State private var configFetched = false
    @State private var enableTranslations = false
    @State private var translations: [String: (title: String, description: String)] = [:]
    @State private var translationConfig: Any?
    @State private var isLanguageInstalled = false
    @State private var isCheckingLanguage = false

    private let config = FeaturePulse.shared

    public init() {}

    /// Check if the user's device language is NOT English AND translation is enabled in dashboard
    private var shouldShowTranslateButton: Bool {
        // Check if translation is enabled in dashboard settings
        guard config.showTranslation else {
            return false
        }

        // Check iOS version and device language
        if #available(iOS 18.0, *) {
            let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            // Check if language starts with "en" to handle all English variants (en-US, en-GB, etc.)
            return !deviceLanguage.hasPrefix("en")
        }
        return false
    }

    /// Check if translation language is installed
    @available(iOS 18.0, *)
    private func checkLanguageAvailability() async {
        #if canImport(Translation)
            isCheckingLanguage = true
            let languageAvailability = LanguageAvailability()
            let status = await languageAvailability.status(
                from: Locale.Language(identifier: "en"),
                to: Locale.current.language
            )

            await MainActor.run {
                isLanguageInstalled = (status == .installed)
                isCheckingLanguage = false
            }
        #endif
    }

    /// Get appropriate button label based on translation state
    private var translateButtonLabel: String {
        // Only show "See Original" if translations are enabled AND we have actual translations
        (enableTranslations && !translations.isEmpty) ? L10n.showOriginal : L10n.translateAll
    }

    /// Translate button view for non-English users
    @ViewBuilder
    private var translateButton: some View {
        if shouldShowTranslateButton, !viewModel.isLoading {
            HStack {
                Button {
                    if enableTranslations {
                        // Have translations showing - turn off
                        withAnimation {
                            enableTranslations = false
                        }
                    } else {
                        // Check if we have cached translations
                        if !translations.isEmpty {
                            // We have cached translations - just show them
                            withAnimation {
                                enableTranslations = true
                            }
                        } else {
                            // No cached translations - trigger new translation
                            if #available(iOS 18.0, *) {
                                #if canImport(Translation)
                                    // Invalidate existing config
                                    if var config = translationConfig as? TranslationSession.Configuration {
                                        config.invalidate()
                                    }
                                    // Clear config first to force download popup again
                                    translationConfig = nil
                                    // Create new config in next frame to re-trigger translationTask
                                    Task { @MainActor in
                                        // 0.1 second to force download popup again
                                        try? await Task.sleep(nanoseconds: 100_000_000)

                                        translationConfig = TranslationSession.Configuration(
                                            source: Locale.Language(identifier: "en"),
                                            target: Locale.current.language
                                        )
                                    }
                                #endif
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "translate")
                        if isCheckingLanguage {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text(translateButtonLabel)
                        }
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }

    /// Alert data for restriction message
    private struct RestrictionAlert: Identifiable {
        let id = UUID()
        let subscriptionName: String
    }

    public var body: some View {
        Group {
            if let error = viewModel.error {
                ContentUnavailableView {
                    Label(L10n.loadingError, systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error.localizedDescription)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.loadFeatureRequests()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                featureRequestsList
                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                    .modifier(ShimmerModifier(isLoading: viewModel.isLoading))
            }
        }
        .navigationTitle(L10n.featureRequests)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.requestFeature, systemImage: "plus") {
                    handleFeatureRequestTap()
                }
                .foregroundStyle(Color(uiColor: .systemBackground))
                .tint(Color(uiColor: .label))
                .disabled(!configFetched)
            }
        }
        .sheet(
            isPresented: $showingNewRequest,
            onDismiss: {
                Task {
                    await viewModel.loadFeatureRequests()
                }
            },
            content: {
                NewFeatureRequestView()
            }
        )
        .alert("Vote Error", isPresented: $viewModel.showVoteError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.voteErrorMessage {
                Text(errorMessage)
            }
        }
        .alert(item: $restrictionAlert) { alert in
            Alert(
                title: Text(L10n.restrictionAlertTitle),
                message: Text(L10n.restrictionMessage(subscriptionName: alert.subscriptionName)),
                dismissButton: .default(Text(L10n.ok))
            )
        }
        .task {
            await viewModel.loadFeatureRequests()
            configFetched = true

            // Check if translation language is available
            if shouldShowTranslateButton {
                if #available(iOS 18.0, *) {
                    await checkLanguageAvailability()
                }
            }
        }
    }

    private func handleFeatureRequestTap() {
        if !config.permissions.canCreateFeatureRequest {
            handleRestriction()
        } else {
            showingNewRequest = true
        }
    }

    private func handleRestriction() {
        if let mode = config.restrictionMode {
            switch mode {
            case let .alert(subscriptionName):
                restrictionAlert = RestrictionAlert(subscriptionName: subscriptionName)
            case let .callback(handler):
                handler()
            }
        } else {
            // Default: show alert with "Pro"
            restrictionAlert = RestrictionAlert(subscriptionName: "Pro")
        }
    }

    /// Create a binding to a specific feature request by ID
    private func requestBinding(for id: String) -> Binding<FeatureRequest>? {
        guard let index = viewModel.featureRequests.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        return Binding(
            get: { viewModel.featureRequests[index] },
            set: { viewModel.featureRequests[index] = $0 }
        )
    }

    private var featureRequestsList: some View {
        Group {
            // Show empty state if no feature requests and not loading
            if viewModel.featureRequests.isEmpty, !viewModel.isLoading {
                emptyStateView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Translate button for non-English users
                        translateButton

                        // Feature requests list
                        VStack {
                            ForEach(displayedRequests) { request in
                                Button {
                                    selectedRequest = request
                                } label: {
                                    FeatureRequestRow(
                                        request: request,
                                        hasVoted: viewModel.hasVoted(for: request.id),
                                        translatedTitle: enableTranslations ? translations[request.id]?.title : nil,
                                        translatedDescription: enableTranslations ? translations[request.id]?.description : nil
                                    ) {
                                        await viewModel.toggleVote(for: request.id)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, shouldShowTranslateButton ? 16 : 24)

                        // CTA Section at bottom
                        VStack(alignment: .leading, spacing: 12) {
                            Text(L10n.ctaMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)

                            Button {
                                handleFeatureRequestTap()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.body.weight(.semibold))
                                    Text(L10n.requestFeature)
                                        .font(.body.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(uiColor: .label))
                                .foregroundStyle(Color(uiColor: .systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 32)
                    }
                }
                .refreshable {
                    Task {
                        await viewModel.loadFeatureRequests(isRefresh: true)
                    }
                }
            }
        }
        .sheet(item: $selectedRequest) { request in
            if let binding = requestBinding(for: request.id) {
                FeatureRequestDetailView(
                    request: binding,
                    hasVoted: viewModel.hasVoted(for: request.id),
                    translatedTitle: enableTranslations ? translations[request.id]?.title : nil,
                    translatedDescription: enableTranslations ? translations[request.id]?.description : nil
                ) {
                    await viewModel.toggleVote(for: request.id)
                }
            }
        }
        .applyBatchTranslation(
            config: translationConfig,
            requests: viewModel.featureRequests,
            translations: $translations,
            enableTranslations: $enableTranslations,
            isLanguageInstalled: $isLanguageInstalled
        )
    }

    /// Returns feature requests or placeholder data when loading
    private var displayedRequests: [FeatureRequest] {
        if viewModel.isLoading, viewModel.featureRequests.isEmpty {
            // Show placeholder items while loading
            // Use previous count if available, otherwise default to 5
            let placeholderCount = max(viewModel.previousRequestCount, 5)
            return (0 ..< placeholderCount).map { index in
                FeatureRequest(
                    id: "placeholder-\(index)",
                    title: "Loading feature request...",
                    description: "Please wait while we load the feature requests from the server.",
                    status: .pending,
                    voteCount: 0,
                    hasVoted: false
                )
            }
        }
        return viewModel.featureRequests
    }

    /// Empty state view when there are no feature requests
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 64))
                .foregroundStyle(FeaturePulse.shared.primaryColor)
                .symbolEffect(.pulse)

            VStack(spacing: 8) {
                Text(L10n.emptyStateTitle)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(L10n.emptyStateMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                handleFeatureRequestTap()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                    Text(L10n.requestFeature)
                        .font(.body.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(uiColor: .label))
                .foregroundStyle(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Batch Translation Extension

private extension View {
    @ViewBuilder
    func applyBatchTranslation(
        config: Any?,
        requests: [FeatureRequest],
        translations: Binding<[String: (title: String, description: String)]>,
        enableTranslations: Binding<Bool>,
        isLanguageInstalled: Binding<Bool>
    ) -> some View {
        if #available(iOS 18.0, *) {
            #if canImport(Translation)
                translationTask(config as? TranslationSession.Configuration) { session in
                    do {
                        var translatedAny = false

                        // Translate all feature requests in batch
                        for request in requests {
                            // Skip if already translated
                            guard translations.wrappedValue[request.id] == nil else { continue }

                            // Capture text values locally to avoid data races
                            let titleToTranslate = request.title
                            let descToTranslate = request.description

                            // Translate title and description with error handling
                            // Use Task to avoid data races with session
                            let titleResponse = try await Task { @MainActor in
                                try await session.translate(titleToTranslate)
                            }.value

                            let descResponse = try await Task { @MainActor in
                                try await session.translate(descToTranslate)
                            }.value

                            await MainActor.run {
                                translations.wrappedValue[request.id] = (
                                    title: titleResponse.targetText,
                                    description: descResponse.targetText
                                )
                                translatedAny = true
                            }
                        }

                        // Only enable translations if we successfully translated something
                        if translatedAny {
                            await MainActor.run {
                                enableTranslations.wrappedValue = true
                            }
                        }
                    } catch {
                        // Translation failed - make sure button stays off and mark language as not installed
                        await MainActor.run {
                            enableTranslations.wrappedValue = false
                            isLanguageInstalled.wrappedValue = false
                        }
                    }
                }
                .id((config as? TranslationSession.Configuration).debugDescription) // Force show download popup again
            #else
                self
            #endif
        } else {
            self
        }
    }
}
