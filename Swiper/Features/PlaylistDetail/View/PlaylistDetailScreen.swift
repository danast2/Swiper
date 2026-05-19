//
//  PlaylistDetailScreen.swift
//  Swiper
//

import SwiftUI

struct PlaylistDetailScreen: View {
    let playlist: PlaylistRef
    @State private var viewModel: PlaylistDetailViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    init(playlist: PlaylistRef, viewModel: PlaylistDetailViewModel) {
        self.playlist = playlist
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let error):
                errorView(for: error)
            case .loaded:
                grid
            }
        }
        .navigationTitle(playlist.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if case .idle = viewModel.state {
                await viewModel.load()
            }
        }
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.cards) { card in
                    NavigationLink(
                        value: CardDestination(playlist: playlist, cardID: card.id)
                    ) {
                        CardGridTile(hit: CardHit(card: card, playlist: playlist))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private func errorView(for error: NetworkError) -> some View {
        VStack(spacing: 16) {
            Text("error.title")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            Button("error.retry") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
