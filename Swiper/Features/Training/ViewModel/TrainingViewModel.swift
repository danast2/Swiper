//
//  TrainingViewModel.swift
//  Swiper
//

import Foundation
import OSLog

@MainActor
@Observable
final class TrainingViewModel {
    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(NetworkError)
    }

    private(set) var state: LoadState = .idle
    private(set) var learnedCount = 0
    private(set) var totalCount = 0
    private(set) var isSessionComplete = false
    var deck: [Card] = []
    var selectedCard: Card?
    var popTrigger: CardSwipeDirection?

    var dueTodayCount: Int { deck.count }

    private var allCards: [Card] = []
    private var progressByID: [String: TrainingCardProgress] = [:]
    private var progressSaveRevision = 0

    private let service: PlaylistServicing
    private let playlistID: String
    private let progressStore: TrainingProgressStoring
    private let calendar: Calendar
    private let dayDuration: TimeInterval = 86_400
    private let logger = Logger(subsystem: "com.daniildem.project.Swiper", category: "Training")

    init(
        service: PlaylistServicing,
        playlistID: String,
        progressStore: TrainingProgressStoring,
        calendar: Calendar = .current
    ) {
        self.service = service
        self.playlistID = playlistID
        self.progressStore = progressStore
        self.calendar = calendar
    }

    func load() async {
        state = .loading
        do {
            let cards = try await service.fetchCards(id: playlistID)
            let storedProgress = await progressStore.loadProgress(playlistID: playlistID)

            allCards = cards
            totalCount = allCards.count
            progressByID = progressDictionary(from: storedProgress)
            rebuildDeck(now: Date())
            state = .loaded
            logger.debug("Loaded \(self.deck.count) training cards")
        } catch let error as NetworkError {
            state = .failed(error)
            logger.error("Failed to load training playlist: \(error.localizedDescription)")
        } catch {
            state = .failed(.transport(error))
            logger.error("Failed to load training playlist: \(error.localizedDescription)")
        }
    }

    func onSwipe(_ card: Card, direction: CardSwipeDirection) {
        let now = Date()
        switch direction {
        case .right:
            remember(card, now: now)
        case .left:
            forget(card, now: now)
        case .idle:
            return
        }
        selectedCard = deck.first
        saveProgress()
    }

    func onNoMoreCards() {
        isSessionComplete = deck.isEmpty
    }

    private func remember(_ card: Card, now: Date) {
        let cutoff = startOfTomorrow(for: now)
        let oldProgress = progressByID[card.id]
        let wasLearned = oldProgress.map { isLearned($0, cutoff: cutoff) } ?? false
        var progress = oldProgress ?? TrainingCardProgress(cardID: card.id)
        let firstRememberedAt = progress.firstRememberedAt ?? now

        progress.rememberedCount += 1
        progress.firstRememberedAt = firstRememberedAt
        progress.lastReviewedAt = now
        progress.nextReviewAt = nextReviewDate(
            firstRememberedAt: firstRememberedAt,
            rememberedCount: progress.rememberedCount,
            now: now
        )
        progressByID[card.id] = progress
        updateLearnedCount(
            wasLearned: wasLearned,
            isLearned: isLearned(progress, cutoff: cutoff)
        )
    }

    private func forget(_ card: Card, now: Date) {
        let cutoff = startOfTomorrow(for: now)
        let oldProgress = progressByID[card.id]
        let wasLearned = oldProgress.map { isLearned($0, cutoff: cutoff) } ?? false
        var progress = oldProgress ?? TrainingCardProgress(cardID: card.id)
        progress.forgottenCount += 1
        progress.lastReviewedAt = now
        progress.nextReviewAt = now
        progressByID[card.id] = progress
        updateLearnedCount(
            wasLearned: wasLearned,
            isLearned: isLearned(progress, cutoff: cutoff)
        )
        deck.append(card)
        isSessionComplete = false
    }

    private func rebuildDeck(now: Date) {
        let cutoff = startOfTomorrow(for: now)
        deck = allCards.filter { card in
            guard let progress = progressByID[card.id] else { return true }
            return isDueToday(progress, cutoff: cutoff)
        }
        selectedCard = deck.first
        isSessionComplete = deck.isEmpty
        recalculateLearnedCount(now: now)
    }

    private func isDueToday(_ progress: TrainingCardProgress, cutoff: Date) -> Bool {
        guard progress.rememberedCount > 0, let nextReviewAt = progress.nextReviewAt else {
            return true
        }
        return nextReviewAt < cutoff
    }

    private func recalculateLearnedCount(now: Date) {
        let cutoff = startOfTomorrow(for: now)
        learnedCount = allCards.filter { card in
            guard let progress = progressByID[card.id] else { return false }
            return isLearned(progress, cutoff: cutoff)
        }.count
    }

    private func isLearned(_ progress: TrainingCardProgress, cutoff: Date) -> Bool {
        guard progress.rememberedCount > 0, let nextReviewAt = progress.nextReviewAt else {
            return false
        }
        return nextReviewAt >= cutoff
    }

    private func updateLearnedCount(wasLearned: Bool, isLearned: Bool) {
        guard wasLearned != isLearned else { return }
        learnedCount += isLearned ? 1 : -1
    }

    private func nextReviewDate(
        firstRememberedAt: Date,
        rememberedCount: Int,
        now: Date
    ) -> Date {
        guard rememberedCount > 1 else {
            return firstRememberedAt.addingTimeInterval(dayDuration)
        }
        let daysSinceFirstRemembering = max(
            0,
            now.timeIntervalSince(firstRememberedAt) / dayDuration
        )
        let nextReviewDay = 2.5 * daysSinceFirstRemembering + 1
        return firstRememberedAt.addingTimeInterval(nextReviewDay * dayDuration)
    }

    private func startOfTomorrow(for date: Date) -> Date {
        let startOfToday = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? date
    }

    private func progressDictionary(
        from progress: [TrainingCardProgress]
    ) -> [String: TrainingCardProgress] {
        var result: [String: TrainingCardProgress] = [:]
        progress.forEach { result[$0.cardID] = $0 }
        return result
    }

    private func saveProgress() {
        progressSaveRevision += 1
        let revision = progressSaveRevision
        let progress = Array(progressByID.values)
        Task.detached(priority: .utility) { [progressStore, playlistID, progress, revision] in
            await progressStore.saveProgress(
                progress,
                playlistID: playlistID,
                revision: revision
            )
        }
    }
}
