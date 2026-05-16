//
//  SwiperScreen.swift
//  Swiper
//

import SwiftUI

struct SwiperScreen: View {
    @State private var viewModel: SwiperViewModel

    init(viewModel: SwiperViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
            case .failed(let error):
                errorView(for: error)
            case .loaded:
                cardDeck
            }
        }
        .task {
            if case .idle = viewModel.state {
                await viewModel.load()
            }
        }
    }

    private var cardDeck: some View {
        CardSwipeView(
            items: $viewModel.deck,
            selectedItem: $viewModel.selectedCard,
            popTrigger: $viewModel.popTrigger
        ) { card, progress, direction in
            SwiperCardContent(
                card: card,
                progress: progress,
                direction: direction,
                playsVideo: card.id == viewModel.selectedCard?.id
            )
        }
        .onSwipeEnd { card, direction in
            viewModel.onSwipe(card, direction: direction)
        }
        .onNoMoreCardsLeft {
            viewModel.onNoMoreCards()
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
