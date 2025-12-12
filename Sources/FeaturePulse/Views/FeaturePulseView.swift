import SwiftUI

/// Main view displaying list of feature requests
public struct FeaturePulseView: View {
    @State private var viewModel = FeaturePulseViewModel()
    @State private var showingNewRequest = false
    @State private var selectedRequest: FeatureRequest?

    public init() {}

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
                    showingNewRequest = true
                }
                .foregroundStyle(Color(uiColor: .systemBackground))
                .tint(Color(uiColor: .label))
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
        .task {
            await viewModel.loadFeatureRequests()
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
            if viewModel.featureRequests.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Feature requests list
                        VStack {
                            ForEach(displayedRequests) { request in
                                Button {
                                    selectedRequest = request
                                } label: {
                                    FeatureRequestRow(
                                        request: request,
                                        hasVoted: viewModel.hasVoted(for: request.id)
                                    ) {
                                        await viewModel.toggleVote(for: request.id)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.top, 24)

                        // CTA Section at bottom
                        VStack(alignment: .leading, spacing: 12) {
                            Text(L10n.ctaMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)

                            Button {
                                showingNewRequest = true
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
                    hasVoted: viewModel.hasVoted(for: request.id)
                ) {
                    await viewModel.toggleVote(for: request.id)
                }
            }
        }
    }
    
    /// Returns feature requests or placeholder data when loading
    private var displayedRequests: [FeatureRequest] {
        if viewModel.isLoading && viewModel.featureRequests.isEmpty {
            // Show placeholder items while loading
            // Use previous count if available, otherwise default to 5
            let placeholderCount = max(viewModel.previousRequestCount, 5)
            return (0..<placeholderCount).map { index in
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
                .foregroundStyle(FeaturePulseConfiguration.shared.primaryColor)
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
                showingNewRequest = true
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
