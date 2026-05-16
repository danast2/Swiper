//
//  SwiperViewModel.swift
//  Swiper
//

import Foundation
import OSLog

@MainActor
@Observable
final class SwiperViewModel {
    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(NetworkError)
    }

    private(set) var state: LoadState = .idle
    private(set) var swipedCardIDs: Set<String> = []
    var deck: [Card] = []
    var selectedCard: Card?
    var popTrigger: CardSwipeDirection?

    private let service: PlaylistServicing
    private let playlistID: String
    private let initialCardID: String?
    private let logger = Logger(subsystem: "com.daniildem.project.Swiper", category: "Swiper")

    init(service: PlaylistServicing, playlistID: String, initialCardID: String? = nil) {
        self.service = service
        self.playlistID = playlistID
        self.initialCardID = initialCardID
    }

    func load() async {
        state = .loading
        do {
            let cards = try await service.fetchCards(id: playlistID)
            let initialCardID = initialCardID
            let arrangedDeck = await Task.detached(priority: .userInitiated) {
                Self.arrangeDeck(from: cards, startingAt: initialCardID)
            }.value
            deck = arrangedDeck
            state = .loaded
            logger.debug("Loaded \(self.deck.count) cards")
        } catch let error as NetworkError {
            state = .failed(error)
            logger.error("Failed to load playlist: \(error.localizedDescription)")
        } catch {
            state = .failed(.transport(error))
            logger.error("Failed to load playlist: \(error.localizedDescription)")
        }
    }

    func onSwipe(_ card: Card, direction: CardSwipeDirection) {
        swipedCardIDs.insert(card.id)
        logger.debug("Swiped \(String(describing: direction)) on \(card.title)")
    }

    func onNoMoreCards() {
        logger.debug("No more cards")
    }

    private nonisolated static func arrangeDeck(
        from cards: [Card],
        startingAt cardID: String?
    ) -> [Card] {
        guard let cardID, let idx = cards.firstIndex(where: { $0.id == cardID }) else {
            return cards
        }
        let from = Array(cards[idx...])
        let before = Array(cards[..<idx])
        return from + before
    }
}
