import SwiftUI

/// View for creating a new feature request
public struct NewFeatureRequestView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var title = ""
  @State private var description = ""
  @State private var email = ""
  @State private var isSubmitting = false
  @State private var showError = false
  @State private var errorMessage = ""
  @FocusState private var focusedField: Field?

  private enum Field: Hashable {
    case title
    case description
    case email
  }

  public init() {}

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
              .tint(FeaturePulseConfiguration.shared.primaryColor)

            HStack {
              Spacer()
              Text("\(title.count)/50")
                .font(.caption)
                .foregroundStyle(
                  title.count >= 45 ? (title.count == 50 ? .red : .orange) : .secondary)
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
            .submitLabel(FeaturePulseConfiguration.shared.showSdkEmailField ? .next : .send)
            .onSubmit {
              if FeaturePulseConfiguration.shared.showSdkEmailField {
                focusedField = .email
              } else {
                focusedField = nil
                submitFeatureRequest()
              }
            }
            .tint(FeaturePulseConfiguration.shared.primaryColor)
            .lineLimit(5...10)
            .onChange(of: description) { _, newValue in
              if newValue.count > 500 {
                description = String(newValue.prefix(500))
              }
            }

            HStack {
              Spacer()
              Text("\(description.count)/500")
                .font(.caption)
                .foregroundStyle(
                  description.count >= 450
                    ? (description.count == 500 ? .red : .orange) : .secondary)
            }
          }
        } header: {
          Text(L10n.descriptionHeader)
        }

        // Only show email field if enabled by dashboard setting
        if FeaturePulseConfiguration.shared.showSdkEmailField {
          Section {
            TextField(
              L10n.emailOptional,
              text: $email,
              prompt: Text(L10n.emailOptional)
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.send)
            .onSubmit {
              focusedField = nil
              submitFeatureRequest()
            }
            .tint(FeaturePulseConfiguration.shared.primaryColor)
            #if os(iOS)
              .textContentType(.emailAddress)
              .keyboardType(.emailAddress)
              .autocapitalization(.none)
            #endif
            .autocorrectionDisabled()
          }
        }

        Section {
          Button {
            submitFeatureRequest()
          } label: {
            if isSubmitting {
              HStack {
                Spacer()
                ProgressView()
                  .tint(.white)
                Spacer()
              }
            } else {
              HStack {
                Spacer()
                Text(L10n.submit)
                  .fontWeight(.semibold)
                Spacer()
              }
            }
          }
          .disabled(
            title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              || description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting
          )
          .listRowBackground(
            (title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              || description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
              || isSubmitting)
              ? Color.gray.opacity(0.3) : FeaturePulseConfiguration.shared.primaryColor
          )
          .foregroundStyle(FeaturePulseConfiguration.shared.foregroundColor)
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
      }
      .alert(L10n.error, isPresented: $showError) {
        Button(L10n.ok, role: .cancel) {}
      } message: {
        Text(errorMessage)
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

    // Validate email if provided
    if !email.isEmpty && !isValidEmail(email) {
      errorMessage = L10n.invalidEmail
      showError = true
      return
    }

    isSubmitting = true

    Task {
      do {
        try await FeaturePulseAPI.shared.submitFeatureRequest(
          title: title.trimmingCharacters(in: .whitespacesAndNewlines),
          description: description.trimmingCharacters(in: .whitespacesAndNewlines),
          email: email.isEmpty ? nil : email.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        await MainActor.run {
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

  private func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
  }
}
