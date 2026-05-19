//
//  HomeViewModel.swift
//  Swiper
//

import Foundation
import OSLog

@MainActor
@Observable
final class HomeViewModel {
    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(NetworkError)
    }

    private(set) var state: LoadState = .idle
    private(set) var hits: [CardHit] = []

    private let service: PlaylistServicing
    private let playlists: [PlaylistRef]
    private let logger = Logger(subsystem: "com.daniildem.project.Swiper", category: "Home")

    init(service: PlaylistServicing, playlists: [PlaylistRef]) {
        self.service = service
        self.playlists = playlists
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        state = .loading
        do {
            let loaded = try await fetchAll()
            hits = loaded.sorted { lhs, rhs in
                if lhs.playlist.number != rhs.playlist.number {
                    return lhs.playlist.number < rhs.playlist.number
                }
                return lhs.card.id < rhs.card.id
            }
            state = .loaded
            logger.debug("Loaded \(self.hits.count) cards across \(self.playlists.count) playlists")
        } catch let error as NetworkError {
            state = .failed(error)
            logger.error("Failed to load home cards: \(error.localizedDescription)")
        } catch {
            state = .failed(.transport(error))
            logger.error("Failed to load home cards: \(error.localizedDescription)")
        }
    }

    private func fetchAll() async throws -> [CardHit] {
        try await withThrowingTaskGroup(of: [CardHit].self) { group in
            for ref in playlists {
                group.addTask { [service] in
                    let cards = try await service.fetchCards(id: ref.id)
                    return cards.map { CardHit(card: $0, playlist: ref) }
                }
            }
            var hits: [CardHit] = []
            for try await chunk in group {
                hits.append(contentsOf: chunk)
            }
            return hits
        }
    }
}
