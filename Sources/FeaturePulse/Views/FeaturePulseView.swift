import SwiftUI
#if canImport(Translation)
    import Translation
#endif

public struct FeaturePulseView: View {
    @State private var viewModel = FeaturePulseViewModel()
    @State private var showingNewRequest = false
    @State private var selectedRequest: FeatureRequest?
    @State private var scrollToRequestID: String?
    @State private var highlightedRequestID: String?
    @State private var existingRequestIDs: Set<String> = []
    @State private var restrictionAlert: RestrictionAlert?
    @State private var configFetched = false
    @State private var enableTranslations = false
    @State private var translations: [String: (title: String, description: String)] = [:]
    @State private var translationConfig: Any?
    @State private var isLanguageInstalled = false
    @State private var isCheckingLanguage = false
    @State private var showThankYouToast = false

    private let config = FeaturePulse.shared

    public init() {}

    private var shouldShowTranslateButton: Bool {
        guard config.showTranslation else { return false }

        if #available(iOS 18.0, *) {
            let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            return !deviceLanguage.hasPrefix("en")
        }
        return false
    }

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

    private var translateButtonLabel: String {
        (enableTranslations && !translations.isEmpty) ? L10n.showOriginal : L10n.translateAll
    }

    @ViewBuilder
    private var translateButton: some View {
        if shouldShowTranslateButton, !viewModel.isLoading {
            HStack {
                Button {
                    if enableTranslations {
                        withAnimation {
                            enableTranslations = false
                        }
                    } else {
                        if !translations.isEmpty {
                            withAnimation {
                                enableTranslations = true
                            }
                        } else {
                            if #available(iOS 18.0, *) {
                                #if canImport(Translation)
                                    if var config = translationConfig as? TranslationSession.Configuration {
                                        config.invalidate()
                                    }
                                    translationConfig = nil
                                    Task { @MainActor in
                                        try? await Task.sleep(for: .milliseconds(100))
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
        .sheet(isPresented: $showingNewRequest) {
            NewFeatureRequestView {
                Task {
                    await viewModel.loadFeatureRequests()

                    if let newRequest = viewModel.featureRequests.first(where: { !existingRequestIDs.contains($0.id) }) {
                        await MainActor.run {
                            withAnimation(.smooth) {
                                showThankYouToast = true
                            }
                        }

                        try? await Task.sleep(for: .milliseconds(300))
                        await MainActor.run {
                            scrollToRequestID = newRequest.id
                        }

                        try? await Task.sleep(for: .milliseconds(400))
                        await MainActor.run {
                            withAnimation(.smooth(duration: 0.3)) {
                                highlightedRequestID = newRequest.id
                            }
                        }

                        try? await Task.sleep(for: .seconds(2))
                        await MainActor.run {
                            withAnimation(.smooth(duration: 0.5)) {
                                highlightedRequestID = nil
                            }
                        }

                        try? await Task.sleep(for: .milliseconds(300))
                        await MainActor.run {
                            withAnimation(.smooth) {
                                showThankYouToast = false
                            }
                        }
                    }
                }
            }
        }
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

            if shouldShowTranslateButton {
                if #available(iOS 18.0, *) {
                    await checkLanguageAvailability()
                }
            }
        }
        .overlay(alignment: .top) {
            if showThankYouToast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text(L10n.thankYou)
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(Color(uiColor: .systemBackground))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(uiColor: .label), in: Capsule())
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private func handleFeatureRequestTap() {
        if !config.permissions.canCreateFeatureRequest {
            handleRestriction()
        } else {
            existingRequestIDs = Set(viewModel.featureRequests.map(\.id))
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
            restrictionAlert = RestrictionAlert(subscriptionName: "Pro")
        }
    }

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
            if viewModel.featureRequests.isEmpty, !viewModel.isLoading, configFetched {
                emptyStateView
            } else {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            translateButton

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
                                    .id(request.id)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                FeaturePulse.shared.primaryColor,
                                                lineWidth: highlightedRequestID == request.id ? 2 : 0
                                            )
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, -4)
                                    )
                                }
                            }
                            .padding(.top, shouldShowTranslateButton ? 16 : 24)

                            if configFetched {
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
                                        .frame(minHeight: 32)
                                        .frame(maxWidth: .infinity)
                                    }
                                    .primaryGlassEffect()
                                    .tint(Color(uiColor: .label))
                                    .foregroundStyle(Color(uiColor: .systemBackground))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 32)

                                if config.showWatermark {
                                    HStack(spacing: 6) {
                                        Text(L10n.poweredBy)
                                            .font(.footnote)
                                            .foregroundStyle(.tertiary)
                                        Image("Logo", bundle: .module)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 24)
                                    }
                                    .padding(.bottom, 24)
                                    .unredacted()
                                }
                            }
                        }
                    }
                    .refreshable {
                        Task {
                            await viewModel.loadFeatureRequests(isRefresh: true)
                        }
                    }
                    .onChange(of: scrollToRequestID) { _, newID in
                        if let id = newID {
                            withAnimation(.smooth(duration: 0.5)) {
                                proxy.scrollTo(id, anchor: .center)
                            }
                            scrollToRequestID = nil
                        }
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

    private var displayedRequests: [FeatureRequest] {
        if viewModel.isLoading, viewModel.featureRequests.isEmpty {
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

// MARK: - Batch Translation

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

                        for request in requests {
                            guard translations.wrappedValue[request.id] == nil else { continue }

                            let titleToTranslate = request.title
                            let descToTranslate = request.description

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

                        if translatedAny {
                            await MainActor.run {
                                enableTranslations.wrappedValue = true
                            }
                        }
                    } catch {
                        await MainActor.run {
                            enableTranslations.wrappedValue = false
                            isLanguageInstalled.wrappedValue = false
                        }
                    }
                }
                .id((config as? TranslationSession.Configuration).debugDescription)
            #else
                self
            #endif
        } else {
            self
        }
    }
}

#Preview("Default") {
    FeaturePulseView()
}
