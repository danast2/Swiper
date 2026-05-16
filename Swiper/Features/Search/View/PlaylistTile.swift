//
//  PlaylistTile.swift
//  Swiper
//

import SwiftUI

struct PlaylistTile: View {
    let playlist: PlaylistRef

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            cover
            Text("search.playlist.title \(playlist.number)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
        }
    }

    private var cover: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black.opacity(0.85))
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
            .overlay {
                if let coverAssetName = playlist.coverAssetName {
                    Image(coverAssetName)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
