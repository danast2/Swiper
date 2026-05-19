//
//  CardDetailScreen.swift
//  Swiper
//

import SwiftUI

struct CardDetailScreen: View {
    let playlist: PlaylistRef
    @State private var viewModel: CardDetailViewModel

    init(playlist: PlaylistRef, viewModel: CardDetailViewModel) {
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
            case .notFound:
                ContentUnavailableView(
                    "error.title",
                    systemImage: "questionmark.circle",
                    description: Text(verbatim: "")
                )
            case .loaded:
                if let card = viewModel.card {
                    CardDetailContent(card: card)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
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
