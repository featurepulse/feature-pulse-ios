import SwiftUI

/// View for creating a new feature request
public struct NewFeatureRequestView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""

    @FocusState private var focusedField: Field?

    private var onSubmit: (() -> Void)?

    private enum Field: Hashable {
        case title
        case description
    }

    private var isSubmitDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || isSubmitting
    }

    public init(onSubmit: (() -> Void)? = nil) {
        self.onSubmit = onSubmit
    }

    // MARK: - UI
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField(L10n.title, text: $title, prompt: Text(L10n.titlePlaceholder))
                            .focused($focusedField, equals: .title)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .description
                            }
                            .onChange(of: title) { _, newValue in
                                if newValue.count > 50 {
                                    title = String(newValue.prefix(50))
                                }
                            }
                            .tint(FeaturePulse.shared.primaryColor)
                            .disabled(isSubmitting)

                        HStack {
                            Spacer()
                            Text("\(title.count)/50")
                                .font(.caption)
                                .foregroundStyle(
                                    title.count >= 45 ? (title.count == 50 ? .red : .orange) : .secondary)
                                .contentTransition(.numericText())
                                .animation(.default, value: title.count)
                        }
                    }
                } header: {
                    Text(L10n.titleHeader)
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField(
                            L10n.description,
                            text: $description,
                            prompt: Text(L10n.descriptionPlaceholder),
                            axis: .vertical
                        )
                        .focused($focusedField, equals: .description)
                        .submitLabel(.send)
                        .onSubmit {
                            focusedField = nil
                            submitFeatureRequest()
                        }
                        .tint(FeaturePulse.shared.primaryColor)
                        .lineLimit(5 ... 10)
                        .onChange(of: description) { _, newValue in
                            if newValue.count > 500 {
                                description = String(newValue.prefix(500))
                            }
                        }
                        .disabled(isSubmitting)

                        HStack {
                            Spacer()
                            Text("\(description.count)/500")
                                .font(.caption)
                                .foregroundStyle(
                                    description.count >= 450
                                        ? (description.count == 500 ? .red : .orange) : .secondary)
                                .contentTransition(.numericText())
                                .animation(.default, value: description.count)
                        }
                    }

                } header: {
                    Text(L10n.descriptionHeader)
                }
            }
            .navigationTitle(L10n.newFeatureRequest)
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(L10n.cancel) {
                            dismiss()
                        }
                        .disabled(isSubmitting)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Group {
                            if isSubmitDisabled {
                                glassSubmitButton(tint: Color.gray.opacity(0.3))
                            } else {
                                glassSubmitButton(tint: FeaturePulse.shared.primaryColor)
                            }
                        }
                    }
                }
                .alert(L10n.error, isPresented: $showError) {
                    Button(L10n.ok, role: .cancel) {}
                } message: {
                    Text(errorMessage)
                }
                .onAppear {
                    focusedField = .title
                }
        }
    }

    private func submitFeatureRequest() {
        // Validate title length
        guard title.count >= 3 else {
            errorMessage = L10n.titleTooShort
            showError = true
            return
        }

        guard title.count <= 50 else {
            errorMessage = L10n.titleTooLong
            showError = true
            return
        }

        // Validate description length
        guard description.count >= 10 else {
            errorMessage = L10n.descriptionTooShort
            showError = true
            return
        }

        guard description.count <= 500 else {
            errorMessage = L10n.descriptionTooLong
            showError = true
            return
        }

        // Dismiss keyboard
        focusedField = nil

        withAnimation(.smooth(duration: 0.3)) {
            isSubmitting = true
        }

        Task {
            do {
                try await FeaturePulseAPI.shared.submitFeatureRequest(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                await MainActor.run {
                    onSubmit?()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isSubmitting = false
                }
            }
        }
    }
}

// MARK: - Views
extension NewFeatureRequestView {
    @ViewBuilder
    private func glassSubmitButton(tint: Color) -> some View {
        Button {
            submitFeatureRequest()
        } label: {
            ZStack {
                Text(L10n.submit)
                    .offset(x: isSubmitting ? 50 : 0, y: isSubmitting ? -30 : 0)
                    .scaleEffect(isSubmitting ? 0.5 : 1)
                    .opacity(isSubmitting ? 0 : 1)

                ProgressView()
                    .controlSize(.small)
                    .scaleEffect(isSubmitting ? 1 : 0)
                    .opacity(isSubmitting ? 1 : 0)
            }
            .animation(.smooth(duration: 0.4), value: isSubmitting)
        }
        .foregroundStyle(FeaturePulse.shared.foregroundColor)
        .tint(tint)
        .buttonStyle(.borderedProminent)
        .disabled(isSubmitDisabled)
    }
}

// MARK: - Previews
#Preview("Default") {
    NewFeatureRequestView()
}
