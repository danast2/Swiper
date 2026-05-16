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
                    SwiperScreen(
                        viewModel: SwiperViewModel(
                            service: environment.playlistService,
                            playlistID: destination.playlist.id,
                            initialCardID: destination.initialCardID
                        )
                    )
                    .navigationTitle(Text("search.playlist.title \(destination.playlist.number)"))
                    .navigationBarTitleDisplayMode(.inline)
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
                    NavigationLink(
                        value: PlaylistDestination(playlist: playlist, initialCardID: nil)
                    ) {
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
                    value: PlaylistDestination(playlist: hit.playlist, initialCardID: hit.card.id)
                ) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(hit.card.title)
                                .foregroundStyle(.primary)
                            Text("search.playlist.title \(hit.playlist.number)")
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
