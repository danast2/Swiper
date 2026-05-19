//
//  CardGridTile.swift
//  Swiper
//

import SwiftUI

struct CardGridTile: View {
    let hit: CardHit

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            cover
            Text(hit.card.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)
            if !hit.card.description.isEmpty {
                Text(hit.card.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }

    private var cover: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black.opacity(0.85))
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
            .overlay {
                if let thumbnailURL = hit.card.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .empty:
                            fallbackCover
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            fallbackCover
                        @unknown default:
                            fallbackCover
                        }
                    }
                } else {
                    fallbackCover
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var fallbackCover: some View {
        if let coverAssetName = hit.playlist.coverAssetName {
            Image(coverAssetName)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.white.opacity(0.7))
        }
    }
}
