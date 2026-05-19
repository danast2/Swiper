//
//  SearchScreen.swift
//  Swiper
//

import SwiftUI

struct SearchScreen: View {
    @Environment(\.appEnvironment) private var environment
    @State private var viewModel: SearchViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    init(viewModel: SearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("tab.search")
                .searchable(text: $viewModel.searchText, prompt: Text("search.cards.prompt"))
                .navigationDestination(for: PlaylistDestination.self) { destination in
                    PlaylistDetailScreen(
                        playlist: destination.playlist,
                        viewModel: PlaylistDetailViewModel(
                            service: environment.playlistService,
                            playlistID: destination.playlist.id
                        )
                    )
                }
                .navigationDestination(for: CardDestination.self) { destination in
                    CardDetailScreen(
                        playlist: destination.playlist,
                        viewModel: CardDetailViewModel(
                            service: environment.playlistService,
                            playlistID: destination.playlist.id,
                            cardID: destination.cardID
                        )
                    )
                }
                .task {
                    await viewModel.loadAllIfNeeded()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.searchText.isEmpty {
            tiles
        } else {
            results
        }
    }

    private var tiles: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(environment.availablePlaylists) { playlist in
                    NavigationLink(value: PlaylistDestination(playlist: playlist)) {
                        PlaylistTile(playlist: playlist)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private var results: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let error):
            VStack(spacing: 12) {
                Text("error.title").font(.headline)
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                Button("error.retry") {
                    Task { await viewModel.loadAllIfNeeded() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        case .loaded:
            List(viewModel.searchResults) { hit in
                NavigationLink(
                    value: CardDestination(playlist: hit.playlist, cardID: hit.card.id)
                ) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(hit.card.title)
                                .foregroundStyle(.primary)
                            if !hit.card.description.isEmpty {
                                Text(hit.card.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            Text(hit.playlist.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .overlay {
                if viewModel.searchResults.isEmpty {
                    ContentUnavailableView.search(text: viewModel.searchText)
                }
            }
        }
    }
}
