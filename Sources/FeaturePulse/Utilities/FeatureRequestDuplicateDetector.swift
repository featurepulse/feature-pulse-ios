import Foundation
#if canImport(FoundationModels)
    import FoundationModels
#endif

struct DuplicateSuggestion: Identifiable, Equatable {
    let request: FeatureRequest

    var id: String { request.id }
}

struct DuplicateSuggestionCandidate: Sendable {
    let request: FeatureRequest
    let score: Double
}

enum FeatureRequestDuplicateDetector {
    typealias SemanticReranker = @Sendable (
        _ title: String,
        _ description: String,
        _ candidates: [DuplicateSuggestionCandidate]
    ) async -> DuplicateSuggestion?

    private enum Tuning {
        static let localDuplicateThreshold = 0.58
        static let candidateThreshold = 0.10
        static let semanticCandidateLimit = 12
    }

    static func suggestion(
        title: String,
        description: String,
        existingRequests: [FeatureRequest],
        semanticReranker: SemanticReranker? = nil
    ) async -> DuplicateSuggestion? {
        guard FeaturePulse.shared.duplicateSuggestionsEnabled else { return nil }

        let candidates = rankedCandidates(
            title: title,
            description: description,
            existingRequests: existingRequests
        )
        guard let strongestCandidate = candidates.first else { return nil }

        if strongestCandidate.score >= Tuning.localDuplicateThreshold {
            return DuplicateSuggestion(request: strongestCandidate.request)
        }

        return await (semanticReranker ?? defaultSemanticReranker)(
            title,
            description,
            Array(candidates.prefix(Tuning.semanticCandidateLimit))
        )
    }

    private static func rankedCandidates(
        title: String,
        description: String,
        existingRequests: [FeatureRequest]
    ) -> [DuplicateSuggestionCandidate] {
        let submittedTitleTokens = Set(tokens(from: title))
        let submittedCombinedTokens = Set(tokens(from: "\(title) \(description)"))

        return existingRequests
            .filter { request in
                switch request.status {
                case .pending, .approved, .planned, .inProgress:
                    true
                case .completed, .rejected:
                    false
                }
            }
            .map { request in
                let existingTitleTokens = Set(tokens(from: request.title))
                let existingCombinedTokens = Set(tokens(from: "\(request.title) \(request.description)"))

                let titleScore = max(
                    fuzzyJaccard(submittedTitleTokens, existingTitleTokens),
                    tokenContainmentScore(submittedTitleTokens, in: existingTitleTokens),
                    tokenContainmentScore(submittedTitleTokens, in: existingCombinedTokens),
                    tokenContainmentScore(existingTitleTokens, in: submittedCombinedTokens)
                )
                let combinedScore = fuzzyJaccard(submittedCombinedTokens, existingCombinedTokens)
                let containmentScore = containment(
                    normalizeForContainment("\(title) \(description)"),
                    normalizeForContainment("\(request.title) \(request.description)")
                )

                let score = titleScore * 0.55 + combinedScore * 0.35 + containmentScore * 0.10
                return DuplicateSuggestionCandidate(request: request, score: score)
            }
            .filter { $0.score >= Tuning.candidateThreshold }
            .sorted { lhs, rhs in
                if lhs.score == rhs.score {
                    return lhs.request.voteCount > rhs.request.voteCount
                }
                return lhs.score > rhs.score
            }
    }

    private static func tokens(from text: String) -> [String] {
        let normalized = text
            .lowercased()
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)

        return normalized
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
            .map(stem)
            .filter { token in
                token.count > 2 && !stopWords.contains(token)
            }
    }

    private static func stem(_ token: String) -> String {
        for suffix in ["ing", "ions", "ion", "ies", "es", "s"] where token.count > suffix.count + 3 {
            if token.hasSuffix(suffix) {
                return String(token.dropLast(suffix.count))
            }
        }
        return token
    }

    private static func fuzzyJaccard(_ lhs: Set<String>, _ rhs: Set<String>) -> Double {
        guard !lhs.isEmpty, !rhs.isEmpty else { return 0 }
        let overlap = fuzzyOverlap(lhs, rhs)
        let union = lhs.count + rhs.count - overlap
        guard union > 0 else { return 0 }
        return Double(overlap) / Double(union)
    }

    private static func tokenContainmentScore(
        _ requiredTokens: Set<String>,
        in candidateTokens: Set<String>
    ) -> Double {
        guard requiredTokens.count >= 2 else { return 0 }
        return fuzzyOverlap(requiredTokens, candidateTokens) == requiredTokens.count ? 0.92 : 0
    }

    private static func containment(_ lhs: String, _ rhs: String) -> Double {
        guard !lhs.isEmpty, !rhs.isEmpty else { return 0 }
        if lhs.contains(rhs) || rhs.contains(lhs) { return 1 }
        return 0
    }

    private static func normalizeForContainment(_ text: String) -> String {
        tokens(from: text).joined(separator: " ")
    }

    private static func fuzzyOverlap(_ lhs: Set<String>, _ rhs: Set<String>) -> Int {
        var unmatchedRight = rhs
        var count = 0

        for token in lhs.sorted() {
            if unmatchedRight.remove(token) != nil {
                count += 1
                continue
            }

            guard let fuzzyMatch = unmatchedRight.first(where: { isNearMatch(token, $0) }) else { continue }
            unmatchedRight.remove(fuzzyMatch)
            count += 1
        }

        return count
    }

    private static func isNearMatch(_ lhs: String, _ rhs: String) -> Bool {
        guard lhs.count >= 5, rhs.count >= 5 else { return false }
        let distance = levenshtein(lhs, rhs)
        return distance <= (min(lhs.count, rhs.count) >= 8 ? 2 : 1)
    }

    private static func levenshtein(_ lhs: String, _ rhs: String) -> Int {
        let lhs = Array(lhs)
        let rhs = Array(rhs)
        guard !lhs.isEmpty else { return rhs.count }
        guard !rhs.isEmpty else { return lhs.count }

        var previous = Array(0 ... rhs.count)
        var current = Array(repeating: 0, count: rhs.count + 1)

        for lhsIndex in 1 ... lhs.count {
            current[0] = lhsIndex
            for rhsIndex in 1 ... rhs.count {
                let cost = lhs[lhsIndex - 1] == rhs[rhsIndex - 1] ? 0 : 1
                current[rhsIndex] = min(
                    previous[rhsIndex] + 1,
                    current[rhsIndex - 1] + 1,
                    previous[rhsIndex - 1] + cost
                )
            }
            previous = current
        }

        return previous[rhs.count]
    }

    private static let stopWords: Set<String> = [
        "add", "allow", "also", "and", "app", "can", "could", "feature", "for", "from", "have", "into",
        "like", "make", "need", "new", "please", "request", "should", "that", "the", "this", "want",
        "when", "with", "would",
        "ajouter", "avec", "dans", "demande", "des", "fonctionnalite", "les", "pour", "une", "vous",
        "aber", "als", "auf", "das", "der", "die", "ein", "eine", "fur", "hinzufugen", "mit", "und", "von", "wunsch"
    ]

    static func defaultSemanticReranker(
        title: String,
        description: String,
        candidates: [DuplicateSuggestionCandidate]
    ) async -> DuplicateSuggestion? {
        #if canImport(FoundationModels)
            if #available(iOS 26.0, macOS 26.0, *) {
                return await appleIntelligenceSuggestion(
                    title: title,
                    description: description,
                    candidates: candidates
                )
            }
        #endif

        return nil
    }
}

#if canImport(FoundationModels)
    @available(iOS 26.0, macOS 26.0, *)
    private extension FeatureRequestDuplicateDetector {
        static func appleIntelligenceSuggestion(
            title: String,
            description: String,
            candidates: [DuplicateSuggestionCandidate]
        ) async -> DuplicateSuggestion? {
            guard !candidates.isEmpty else { return nil }

            let model = SystemLanguageModel.default
            guard model.isAvailable else { return nil }

            let session = LanguageModelSession(instructions: """
            You identify duplicate feature requests. Only return a match when the new request asks for the same
            underlying product capability as an existing request.
            Different features in the same category are not duplicates.
            Return HIGH:<existing request ID> for a strong duplicate, or NONE.
            """)

            let candidateLines = candidates.map { candidate in
                "[\(candidate.request.id)] \(candidate.request.title): \(candidate.request.description)"
            }
            .joined(separator: "\n")

            let prompt = """
            New request:
            Title: \(title)
            Description: \(description)

            Existing requests:
            \(candidateLines)

            If one existing request is a strong duplicate, return HIGH: followed by only its ID. Otherwise return NONE.
            """

            do {
                let response = try await session.respond(to: prompt)
                let normalizedResponse = response.content
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "[]"))

                guard normalizedResponse.uppercased() != "NONE" else { return nil }
                let responseID = normalizedResponse
                    .replacingOccurrences(of: "HIGH:", with: "", options: [.caseInsensitive])
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                return candidates
                    .first { candidate in
                        responseID == candidate.request.id || responseID.contains(candidate.request.id)
                    }
                    .map { DuplicateSuggestion(request: $0.request) }
            } catch {
                return nil
            }
        }
    }
#endif
