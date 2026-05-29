// swiftlint:disable file_length
import SwiftUI
#if canImport(Translation)
    @preconcurrency import Translation
#endif

// swiftlint:disable:next type_body_length
public struct FeaturePulseView: View {
    @Environment(\.locale) private var locale

    @StateObject private var viewModel = FeaturePulseViewModel()
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
    @State private var isTranslating = false
    @State private var showThankYouToast = false
    @State private var selectedTab: FeatureTab = .requests
    @State private var sortOption: SortOption?

    private let config = FeaturePulse.shared

    public init() {}

    init(preloaded: FeaturePulseViewModel) {
        _viewModel = StateObject(wrappedValue: preloaded)
        _configFetched = State(initialValue: true)
    }

    private var shouldShowTranslateButton: Bool {
        guard config.showTranslation else { return false }

        if #available(iOS 18.0, macOS 15.0, *) {
            let languageCode = locale.language.languageCode?.identifier ?? "en"
            return !languageCode.hasPrefix("en")
        }
        return false
    }

    @available(iOS 18.0, macOS 15.0, *)
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
                            if #available(iOS 18.0, macOS 15.0, *) {
                                #if canImport(Translation)
                                    isTranslating = true
                                    if var configuration = translationConfig as? TranslationSession.Configuration {
                                        configuration.invalidate()
                                        translationConfig = configuration
                                    } else {
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
                        if isCheckingLanguage || isTranslating {
                            ProgressView()
                                .controlSize(.small)
                            if isTranslating {
                                Text(L10n.translating)
                            }
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
                .disabled(isTranslating)
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
                BackportContentUnavailableView(
                    L10n.loadingError,
                    systemImage: "exclamationmark.triangle",
                    description: error.localizedDescription,
                    actionTitle: L10n.retry
                ) {
                    Task {
                        await viewModel.loadFeatureRequests()
                    }
                }
            } else {
                featureRequestsList
                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                    .modifier(ShimmerModifier(isLoading: viewModel.isLoading))
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
                ToolbarItemGroup(placement: .topBarLeading) {
                    tabAndSortMenus
                }
            #else
                ToolbarItemGroup(placement: .automatic) {
                    tabAndSortMenus
                }
            #endif

            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.requestFeature, systemImage: "plus") {
                    handleFeatureRequestTap()
                }
                .foregroundStyle(Color.systemBackground)
                .tint(Color.label)
                .disabled(!configFetched)
            }
        }
        .sheet(isPresented: $showingNewRequest) {
            NewFeatureRequestView {
                Task {
                    await viewModel.loadFeatureRequests()
                    await MainActor.run {
                        withBackportAnimation(.smooth) { selectedTab = .requests }
                    }

                    let newRequest = viewModel.featureRequests.first { !existingRequestIDs.contains($0.id) }
                    if let newRequest {
                        await MainActor.run {
                            withBackportAnimation(.smooth) {
                                showThankYouToast = true
                            }
                        }

                        try? await Task.sleep(for: .milliseconds(300))
                        await MainActor.run {
                            scrollToRequestID = newRequest.id
                        }

                        try? await Task.sleep(for: .milliseconds(400))
                        await MainActor.run {
                            withBackportAnimation(.smooth(duration: 0.3)) {
                                highlightedRequestID = newRequest.id
                            }
                        }

                        try? await Task.sleep(for: .seconds(2))
                        await MainActor.run {
                            withBackportAnimation(.smooth(duration: 0.5)) {
                                highlightedRequestID = nil
                            }
                        }

                        try? await Task.sleep(for: .milliseconds(300))
                        await MainActor.run {
                            withBackportAnimation(.smooth) {
                                showThankYouToast = false
                            }
                        }
                    }
                }
            }
        }
        .alert("Vote Error", isPresented: $viewModel.showVoteError) {
            Button(L10n.ok, role: .cancel) {}
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
            guard !configFetched else { return }
            await viewModel.loadFeatureRequests()
            configFetched = true

            if shouldShowTranslateButton {
                if #available(iOS 18.0, macOS 15.0, *) {
                    await checkLanguageAvailability()
                }
            }
        }
        .overlay(alignment: .top) {
            if showThankYouToast {
                FeaturePulseThankYouToast()
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

    @ViewBuilder
    private var tabAndSortMenus: some View {
        FeaturePulseToolbarMenus(
            selectedTab: $selectedTab,
            sortOption: $sortOption,
            configFetched: configFetched
        )
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
            if displayedRequests.isEmpty, !viewModel.isLoading, configFetched {
                FeaturePulseEmptyStateView(selectedTab: selectedTab) {
                    handleFeatureRequestTap()
                }
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
                                            translatedDescription: enableTranslations
                                                ? translations[request.id]?.description
                                                : nil
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
                                FeaturePulseListFooter(showWatermark: config.showWatermark) {
                                    handleFeatureRequestTap()
                                }
                            }
                        }
                    }
                    .refreshable {
                        Task {
                            await viewModel.loadFeatureRequests(isRefresh: true)
                        }
                    }
                    .onChangeBackport(of: scrollToRequestID) { newID in
                        if let id = newID {
                            withBackportAnimation(.smooth(duration: 0.5)) {
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
            state: TranslationState(
                translations: $translations,
                enableTranslations: $enableTranslations,
                isLanguageInstalled: $isLanguageInstalled,
                isTranslating: $isTranslating
            )
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

        let filtered = selectedTab.filter(viewModel.featureRequests)

        if selectedTab == .completed {
            return SortOption.newest.sort(filtered)
        }

        return sortOption?.sort(filtered) ?? filtered
    }
}

#Preview("Default") {
    FeaturePulseView()
}

// MARK: - Setting Previews (for dashboard screenshots)

private struct SDKPreview: View {
    var showStatus: Bool
    var showTranslation: Bool

    init(showStatus: Bool = true, showTranslation: Bool = true) {
        self.showStatus = showStatus
        self.showTranslation = showTranslation
        FeaturePulse.shared.showStatus = showStatus
        FeaturePulse.shared.showTranslation = showTranslation
    }

    var body: some View {
        NavigationStack {
            FeaturePulseView(preloaded: FeaturePulseViewModel(preloaded: mockRequests))
            #if os(iOS)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if #available(iOS 26, *) {
                            Button(role: .close) {}
                        } else {
                            Button {} label: { Label("Close", systemImage: "xmark") }
                        }
                    }
                }
            #endif
        }
        .transformEnvironment(\.locale) { locale in
            if showTranslation { locale = Locale(identifier: "ar") }
        }
    }
}

private let mockRequests: [FeatureRequest] = [
    FeatureRequest(
        id: "1", title: "Dark Mode Support", description: "Add dark mode",
        status: .inProgress, voteCount: 142, hasVoted: false
    ),
    FeatureRequest(
        id: "2", title: "Export to PDF", description: "Export data as PDF",
        status: .planned, voteCount: 89, hasVoted: true
    ),
    FeatureRequest(
        id: "3", title: "Offline Mode", description: "Work without internet",
        status: .pending, voteCount: 64, hasVoted: false
    ),
    FeatureRequest(
        id: "4", title: "Push Notifications", description: "Get notified on updates",
        status: .pending, voteCount: 37, hasVoted: false
    )
]

// 4 combinations: s=status, tr=translation (1=ON, 0=OFF)
#Preview("s1-tr1") { SDKPreview(showStatus: true, showTranslation: true) }
#Preview("s1-tr0") { SDKPreview(showStatus: true, showTranslation: false) }
#Preview("s0-tr1") { SDKPreview(showStatus: false, showTranslation: true) }
#Preview("s0-tr0") { SDKPreview(showStatus: false, showTranslation: false) }
