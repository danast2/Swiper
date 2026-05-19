//
//  CardDetailViewModel.swift
//  Swiper
//

import Foundation
import OSLog

@MainActor
@Observable
final class CardDetailViewModel {
    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(NetworkError)
        case notFound
    }

    private(set) var state: LoadState = .idle
    private(set) var card: Card?

    private let service: PlaylistServicing
    private let playlistID: String
    private let cardID: String
    private let logger = Logger(subsystem: "com.daniildem.project.Swiper", category: "CardDetail")

    init(service: PlaylistServicing, playlistID: String, cardID: String) {
        self.service = service
        self.playlistID = playlistID
        self.cardID = cardID
    }

    func load() async {
        state = .loading
        do {
            let cards = try await service.fetchCards(id: playlistID)
            if let match = cards.first(where: { $0.id == cardID }) {
                card = match
                state = .loaded
                logger.debug("Loaded card \(match.title)")
            } else {
                state = .notFound
                logger.error("Card \(self.cardID) not found in playlist \(self.playlistID)")
            }
        } catch let error as NetworkError {
            state = .failed(error)
            logger.error("Failed to load card: \(error.localizedDescription)")
        } catch {
            state = .failed(.transport(error))
            logger.error("Failed to load card: \(error.localizedDescription)")
        }
    }
}
