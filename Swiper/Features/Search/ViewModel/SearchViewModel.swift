//
//  SearchViewModel.swift
//  Swiper
//

import Foundation
import OSLog

@MainActor
@Observable
final class SearchViewModel {
    enum LoadState {
        case idle
        case loading
        case loaded
        case failed(NetworkError)
    }

    struct CardHit: Identifiable, Hashable, Sendable {
        let card: Card
        let playlist: PlaylistRef

        var id: String { "\(playlist.id)/\(card.id)" }
    }

    private(set) var state: LoadState = .idle
    private(set) var allCards: [CardHit] = []
    var searchText: String = ""

    var searchResults: [CardHit] {
        guard !searchText.isEmpty else { return [] }
        return allCards.filter {
            $0.card.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    private let service: PlaylistServicing
    private let playlists: [PlaylistRef]
    private let logger = Logger(subsystem: "com.daniildem.project.Swiper", category: "Search")

    init(service: PlaylistServicing, playlists: [PlaylistRef]) {
        self.service = service
        self.playlists = playlists
    }

    func loadAllIfNeeded() async {
        guard case .idle = state else { return }
        state = .loading
        do {
            let loaded = try await fetchAll()
            allCards = loaded.sorted { lhs, rhs in
                lhs.playlist.number < rhs.playlist.number
            }
            state = .loaded
            logger.debug(
                "Loaded \(self.allCards.count) cards across \(self.playlists.count) playlists"
            )
        } catch let error as NetworkError {
            state = .failed(error)
            logger.error("Failed to load search index: \(error.localizedDescription)")
        } catch {
            state = .failed(.transport(error))
            logger.error("Failed to load search index: \(error.localizedDescription)")
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
