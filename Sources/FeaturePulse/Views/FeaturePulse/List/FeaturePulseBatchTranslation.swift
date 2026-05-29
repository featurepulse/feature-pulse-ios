import SwiftUI
#if canImport(Translation)
    @preconcurrency import Translation
#endif

struct TranslationState {
    var translations: Binding<[String: (title: String, description: String)]>
    var enableTranslations: Binding<Bool>
    var isLanguageInstalled: Binding<Bool>
    var isTranslating: Binding<Bool>
}

extension View {
    @ViewBuilder
    func applyBatchTranslation(
        config: Any?,
        requests: [FeatureRequest],
        state: TranslationState
    ) -> some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            #if canImport(Translation)
                translationTask(config as? TranslationSession.Configuration) { session in
                    await runBatchTranslation(session: session, requests: requests, state: state)
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

#if canImport(Translation)
    @available(iOS 18.0, macOS 15.0, *)
    private func runBatchTranslation(
        session: TranslationSession,
        requests: [FeatureRequest],
        state: TranslationState
    ) async {
        do {
            var translatedAny = false
            var partialTranslations: [String: (title: String?, description: String?)] = [:]

            let batchRequests = await MainActor.run {
                requests
                    .filter { state.translations.wrappedValue[$0.id] == nil }
                    .flatMap { request in
                        [
                            TranslationSession.Request(
                                sourceText: request.title,
                                clientIdentifier: "title:\(request.id)"
                            ),
                            TranslationSession.Request(
                                sourceText: request.description,
                                clientIdentifier: "description:\(request.id)"
                            )
                        ]
                    }
            }

            guard !batchRequests.isEmpty else {
                await MainActor.run { state.isTranslating.wrappedValue = false }
                return
            }

            await MainActor.run { state.isTranslating.wrappedValue = true }

            for try await response in session.translate(batch: batchRequests) {
                translatedAny = await applyResponse(response, into: &partialTranslations, state: state) || translatedAny
            }

            await MainActor.run {
                if translatedAny { state.enableTranslations.wrappedValue = true }
                state.isTranslating.wrappedValue = false
            }
        } catch {
            await MainActor.run {
                state.enableTranslations.wrappedValue = false
                state.isLanguageInstalled.wrappedValue = false
                state.isTranslating.wrappedValue = false
            }
        }
    }

    @available(iOS 18.0, macOS 15.0, *)
    @discardableResult
    private func applyResponse(
        _ response: TranslationSession.Response,
        into partialTranslations: inout [String: (title: String?, description: String?)],
        state: TranslationState
    ) async -> Bool {
        guard let clientID = response.clientIdentifier else { return false }
        let isTitle = clientID.hasPrefix("title:")
        guard isTitle || clientID.hasPrefix("description:") else { return false }
        let requestID = String(clientID.dropFirst(isTitle ? "title:".count : "description:".count))

        var partial = partialTranslations[requestID] ?? (title: nil, description: nil)
        if isTitle { partial.title = response.targetText } else { partial.description = response.targetText }
        partialTranslations[requestID] = partial

        guard let title = partial.title, let description = partial.description else { return false }
        await MainActor.run {
            state.translations.wrappedValue[requestID] = (title: title, description: description)
        }
        return true
    }
#endif
