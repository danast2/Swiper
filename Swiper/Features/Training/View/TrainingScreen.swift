//
//  TrainingScreen.swift
//  Swiper
//

import SwiftUI

struct TrainingScreen: View {
    @State private var viewModel: TrainingViewModel

    init(viewModel: TrainingViewModel) {
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
                loadedContent
            }
        }
        .task {
            if case .idle = viewModel.state {
                await viewModel.load()
            }
        }
    }

    private var loadedContent: some View {
        VStack(spacing: 16) {
            progressHeader

            if viewModel.isSessionComplete {
                emptyState
            } else {
                trainingDeck
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("training.learned \(viewModel.learnedCount) \(viewModel.totalCount)")
                .font(.headline)
            Text("training.dueToday \(viewModel.dueTodayCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var trainingDeck: some View {
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

    private var emptyState: some View {
        ContentUnavailableView(
            "training.empty.title",
            systemImage: "checkmark.circle",
            description: Text("training.empty.description")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
