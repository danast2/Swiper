//
//  CardDetailContent.swift
//  Swiper
//

import SwiftUI

struct CardDetailContent: View {
    let card: Card

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CardSwipeLayout.cardCornerRadius)
                .fill(card.color)

            VStack(spacing: CardSwipeLayout.cardContentSpacing) {
                if let videoURL = card.videoURL {
                    DeferredYandexVideoPlayerView(url: videoURL)
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
        .frame(width: CardSwipeLayout.cardWidth, height: CardSwipeLayout.cardHeight)
        .shadow(radius: CardSwipeLayout.cardShadowRadius)
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
}
