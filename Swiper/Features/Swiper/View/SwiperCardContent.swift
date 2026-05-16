//
//  SwiperCardContent.swift
//  Swiper
//

import SwiftUI

struct SwiperCardContent: View {
    let card: Card
    let progress: CGFloat
    let direction: CardSwipeDirection
    let playsVideo: Bool

    init(
        card: Card,
        progress: CGFloat,
        direction: CardSwipeDirection,
        playsVideo: Bool = true
    ) {
        self.card = card
        self.progress = progress
        self.direction = direction
        self.playsVideo = playsVideo
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CardSwipeLayout.cardCornerRadius)
                .fill(card.color)

            VStack(spacing: CardSwipeLayout.cardContentSpacing) {
                if let videoURL = card.videoURL {
                    videoView(url: videoURL)
                        .frame(
                            width: CardSwipeLayout.videoWidth,
                            height: CardSwipeLayout.videoHeight
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: CardSwipeLayout.videoCornerRadius)
                        )
                }

                Text(card.title)
                    .font(card.videoURL == nil ? .largeTitle : .title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(CardSwipeLayout.titleLineLimit)
                    .minimumScaleFactor(0.8)

                descriptionView
            }
            .padding(CardSwipeLayout.cardContentPadding)
        }
        .overlay(alignment: .top) {
            directionIndicator
                .padding(.top, CardSwipeLayout.cardContentPadding)
        }
        .frame(width: CardSwipeLayout.cardWidth, height: CardSwipeLayout.cardHeight)
        .shadow(radius: CardSwipeLayout.cardShadowRadius)
    }

    @ViewBuilder
    private func videoView(url: URL) -> some View {
        if playsVideo {
            DeferredYandexVideoPlayerView(url: url)
        } else {
            Color.black
        }
    }

    @ViewBuilder
    private var descriptionView: some View {
        if !card.description.isEmpty {
            ScrollView(.vertical, showsIndicators: true) {
                Text(card.description)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: CardSwipeLayout.descriptionMaxHeight)
            .padding(.horizontal, CardSwipeLayout.descriptionHorizontalPadding)
        }
    }

    @ViewBuilder
    private var directionIndicator: some View {
        let isLeft = direction == .left
        Text(isLeft ? "swipe.indicator.forget" : "swipe.indicator.remember")
            .font(.title)
            .foregroundColor(.white)
            .padding(CardSwipeLayout.indicatorPadding)
            .background(isLeft ? Color.red : Color.green)
            .cornerRadius(CardSwipeLayout.cardCornerRadius)
            .opacity(progress)
    }
}
