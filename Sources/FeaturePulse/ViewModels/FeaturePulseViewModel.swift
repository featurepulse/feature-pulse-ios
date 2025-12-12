import SwiftUI

/// ViewModel managing feature requests state and operations
@Observable
final class FeaturePulseViewModel: @unchecked Sendable {
    var featureRequests: [FeatureRequest] = []
    var isLoading = false
    var error: Error?
    var votedRequestIds: Set<String> = []
    var voteErrorMessage: String?
    var showVoteError = false
    var previousRequestCount: Int = 0

    func loadFeatureRequests(isRefresh: Bool = false) async {
        // Only show loading spinner on initial load, not on refresh
        if !isRefresh {
            isLoading = true
        }
        error = nil

        do {
            var requests = try await FeaturePulseAPI.shared.fetchFeatureRequests()

            // Shuffle with seeded random to prevent voting bias
            // Each user sees a different consistent order based on their deviceID
            requests = shuffleWithSeed(requests, seed: FeaturePulseConfiguration.shared.user.deviceID)

            // Store previous count for placeholder sizing
            if !featureRequests.isEmpty {
                previousRequestCount = featureRequests.count
            }

            withAnimation {
                featureRequests = requests
            }

            // Sync voted state from API
            votedRequestIds = Set(featureRequests.filter { $0.hasVoted }.map { $0.id })

            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }

    /// Shuffle array with a deterministic seed to prevent voting bias
    /// - Parameters:
    ///   - array: Array to shuffle
    ///   - seed: Seed string (uses deviceID for consistency)
    /// - Returns: Shuffled array
    private func shuffleWithSeed<T>(_ array: [T], seed: String) -> [T] {
        guard !array.isEmpty else { return array }

        // Create deterministic seed from string using djb2 hash algorithm
        // This is deterministic across app launches (unlike Swift's Hasher)
        var hash: UInt64 = 5381
        for char in seed.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(char)
        }

        // Use a simple Linear Congruential Generator (LCG) for deterministic shuffling
        var rng = SeededRandomGenerator(seed: hash)
        var shuffled = array

        // Fisher-Yates shuffle with seeded random
        for index in stride(from: shuffled.count - 1, through: 1, by: -1) {
            let randomIndex = Int(rng.next() % UInt64(index + 1))
            shuffled.swapAt(index, randomIndex)
        }

        return shuffled
    }

    func toggleVote(for id: String) async -> Bool {
        let hasVoted = votedRequestIds.contains(id)

        do {
            await updateVoteOptimistically(for: id, currentlyVoted: hasVoted)

            if hasVoted {
                try await FeaturePulseAPI.shared.unvoteForFeatureRequest(id: id)
                votedRequestIds.remove(id)
            } else {
                try await FeaturePulseAPI.shared.voteForFeatureRequest(id: id)
                votedRequestIds.insert(id)
            }

            return true
        } catch let error as FeaturePulseError where error == .alreadyVoted {
            votedRequestIds.insert(id)
            return false
        } catch {
            await revertVoteUpdate(for: id, previouslyVoted: hasVoted, error: error)
            return false
        }
    }

    private func updateVoteOptimistically(for id: String, currentlyVoted: Bool) async {
        await MainActor.run {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                updateVoteCount(for: id, increment: !currentlyVoted)
            }
        }
    }

    private func revertVoteUpdate(for id: String, previouslyVoted: Bool, error: Error) async {
        await MainActor.run {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                updateVoteCount(for: id, increment: previouslyVoted)
            }
            voteErrorMessage = error.localizedDescription
            showVoteError = true
        }
    }

    private func updateVoteCount(for id: String, increment: Bool) {
        guard let index = featureRequests.firstIndex(where: { $0.id == id }) else { return }

        let current = featureRequests[index]
        let newVoteCount = increment ? current.voteCount + 1 : max(0, current.voteCount - 1)

        featureRequests[index] = FeatureRequest(
            id: current.id,
            title: current.title,
            description: current.description,
            status: current.status,
            voteCount: newVoteCount,
            hasVoted: increment
        )
    }

    func hasVoted(for id: String) -> Bool {
        votedRequestIds.contains(id)
    }
}

/// Simple seeded random number generator for deterministic shuffling
private struct SeededRandomGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // Linear Congruential Generator (LCG) - same as used in glibc
        state = (state &* 1_103_515_245 &+ 12345) & 0x7FFF_FFFF
        return state
    }
}
