//
//  PlaylistDetailViewModel.swift
//  Swiper
//

import Foundation
import OSLog

@MainActor
@Observable
final class PlaylistDetailViewModel {
    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(NetworkError)
    }

    private(set) var state: LoadState = .idle
    private(set) var cards: [Card] = []

    private let service: PlaylistServicing
    private let playlistID: String
    private let logger = Logger(
        subsystem: "com.daniildem.project.Swiper",
        category: "PlaylistDetail"
    )

    init(service: PlaylistServicing, playlistID: String) {
        self.service = service
        self.playlistID = playlistID
    }

    func load() async {
        state = .loading
        do {
            cards = try await service.fetchCards(id: playlistID)
            state = .loaded
            logger.debug("Loaded \(self.cards.count) cards for playlist \(self.playlistID)")
        } catch let error as NetworkError {
            state = .failed(error)
            logger.error("Failed to load playlist: \(error.localizedDescription)")
        } catch {
            state = .failed(.transport(error))
            logger.error("Failed to load playlist: \(error.localizedDescription)")
        }
    }
}
