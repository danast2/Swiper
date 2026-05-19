//
//  HomeScreen.swift
//  Swiper
//

import SwiftUI

struct HomeScreen: View {
    @Environment(\.appEnvironment) private var environment
    @State private var viewModel: HomeViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("tab.home")
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
                    await viewModel.loadIfNeeded()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
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

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.hits) { hit in
                    NavigationLink(
                        value: CardDestination(playlist: hit.playlist, cardID: hit.card.id)
                    ) {
                        CardGridTile(hit: hit)
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
                Task { await viewModel.loadIfNeeded() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
