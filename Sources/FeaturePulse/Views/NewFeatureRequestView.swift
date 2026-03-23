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
        case title, description
    }

    private enum Limits {
        static let titleMax = 50
        static let titleWarning = 45
        static let titleMin = 3
        static let descriptionMax = 500
        static let descriptionWarning = 450
        static let descriptionMin = 10
    }

    private var isSubmitDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || isSubmitting
    }

    public init(onSubmit: (() -> Void)? = nil) {
        self.onSubmit = onSubmit
    }

    // MARK: - Shared subviews
    private func charCounter(count: Int, limit: Int, threshold: Int) -> some View {
        HStack {
            Spacer()
            Text(verbatim: "\(count)/\(limit)")
                .font(.caption)
                .foregroundStyle(count >= threshold ? (count == limit ? .red : .orange) : .secondary)
                .contentTransition(.numericText())
                .animation(.default, value: count)
        }
    }

    private var submitButton: some View {
        glassSubmitButton(tint: isSubmitDisabled ? Color.gray.opacity(0.3) : FeaturePulse.shared.primaryColor)
    }

    // MARK: - Body
    public var body: some View {
        NavigationStack {
            #if os(macOS)
            macOSContent
            #else
            iOSContent
            #endif
        }
    }

    // MARK: - macOS
    #if os(macOS)
    private var macOSContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n.newFeatureRequest).font(.headline)

            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.titleHeader).font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
                TextField(L10n.titlePlaceholder, text: $title)
                    .focused($focusedField, equals: .title)
                    .textFieldStyle(.roundedBorder)
                    .tint(FeaturePulse.shared.primaryColor)
                    .disabled(isSubmitting)
                    .onChange(of: title) { _, v in if v.count > Limits.titleMax { title = String(v.prefix(Limits.titleMax)) } }
                charCounter(count: title.count, limit: Limits.titleMax, threshold: Limits.titleWarning)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.descriptionHeader).font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
                TextEditor(text: $description)
                    .focused($focusedField, equals: .description)
                    .frame(minHeight: 100)
                    .tint(FeaturePulse.shared.primaryColor)
                    .disabled(isSubmitting)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.3), lineWidth: 1))
                    .onChange(of: description) { _, v in if v.count > Limits.descriptionMax { description = String(v.prefix(Limits.descriptionMax)) } }
                charCounter(count: description.count, limit: Limits.descriptionMax, threshold: Limits.descriptionWarning)
            }

            Divider()

            HStack {
                Spacer()
                Button(L10n.cancel) { dismiss() }.disabled(isSubmitting)
                submitButton
            }
        }
        .padding(24)
        .frame(minWidth: 420)
        .commonModifiers(showError: $showError, errorMessage: errorMessage, onAppear: { focusedField = .title })
    }
    #endif

    // MARK: - iOS
    private var iOSContent: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    TextField(L10n.title, text: $title, prompt: Text(L10n.titlePlaceholder))
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .description }
                        .tint(FeaturePulse.shared.primaryColor)
                        .disabled(isSubmitting)
                        .onChange(of: title) { _, v in if v.count > Limits.titleMax { title = String(v.prefix(Limits.titleMax)) } }
                    charCounter(count: title.count, limit: Limits.titleMax, threshold: Limits.titleWarning)
                }
            } header: { Text(L10n.titleHeader) }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    TextField(L10n.description, text: $description, prompt: Text(L10n.descriptionPlaceholder), axis: .vertical)
                        .focused($focusedField, equals: .description)
                        .submitLabel(.send)
                        .onSubmit { focusedField = nil; submitFeatureRequest() }
                        .tint(FeaturePulse.shared.primaryColor)
                        .lineLimit(5...10)
                        .disabled(isSubmitting)
                        .onChange(of: description) { _, v in if v.count > Limits.descriptionMax { description = String(v.prefix(Limits.descriptionMax)) } }
                    charCounter(count: description.count, limit: Limits.descriptionMax, threshold: Limits.descriptionWarning)
                }
            } header: { Text(L10n.descriptionHeader) }
        }
        .navigationTitle(L10n.newFeatureRequest)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n.cancel) { dismiss() }.disabled(isSubmitting)
            }
            ToolbarItem(placement: .confirmationAction) { submitButton }
        }
        .commonModifiers(showError: $showError, errorMessage: errorMessage, onAppear: { focusedField = .title })
    }

    // MARK: - Submit
    private func submitFeatureRequest() {
        guard title.count >= Limits.titleMin else { errorMessage = L10n.titleTooShort; showError = true; return }
        guard title.count <= Limits.titleMax else { errorMessage = L10n.titleTooLong; showError = true; return }
        guard description.count >= Limits.descriptionMin else { errorMessage = L10n.descriptionTooShort; showError = true; return }
        guard description.count <= Limits.descriptionMax else { errorMessage = L10n.descriptionTooLong; showError = true; return }

        focusedField = nil
        withAnimation(.smooth(duration: 0.3)) { isSubmitting = true }

        Task {
            do {
                try await FeaturePulseAPI.shared.submitFeatureRequest(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                await MainActor.run { onSubmit?(); dismiss() }
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

// MARK: - Submit Button

extension NewFeatureRequestView {
    @ViewBuilder
    private func glassSubmitButton(tint: Color) -> some View {
        Button { submitFeatureRequest() } label: {
            ZStack {
                Text(L10n.submit)
                    #if os(iOS)
                    .offset(x: isSubmitting ? 50 : 0, y: isSubmitting ? -30 : 0)
                    .scaleEffect(isSubmitting ? 0.5 : 1)
                    #endif
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

// MARK: - Shared View Modifier
private extension View {

    func commonModifiers(
        showError: Binding<Bool>,
        errorMessage: String,
        onAppear: @escaping () -> Void
    ) -> some View {
        self
            .alert(L10n.error, isPresented: showError) {
                Button(L10n.ok, role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear(perform: onAppear)
    }
}

// MARK: - Previews
#Preview("Default") {
    NewFeatureRequestView()
}
