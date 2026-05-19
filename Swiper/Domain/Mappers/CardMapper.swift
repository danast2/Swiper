//
//  CardMapper.swift
//  Swiper
//

import Foundation
import SwiftUI

enum CardMapper {
    private static let formatQueryToStrip = "&format=json"
    private static let preferredThumbnailWidth = 854

    static func map(_ playlist: PlaylistDTO) -> [Card] {
        playlist.playlistItems.map { item in
            let sanitizedURL = item.playerURL.replacingOccurrences(
                of: formatQueryToStrip,
                with: ""
            )
            return Card(
                id: item.contentID,
                title: item.title,
                description: item.description?.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? "",
                color: .black,
                videoURL: URL(string: sanitizedURL),
                thumbnailURL: thumbnailURL(for: item)
            )
        }
    }

    private static func thumbnailURL(for item: PlaylistItemDTO) -> URL? {
        if let best = bestJPEGThumbnail(from: item.thumbnails),
           let url = URL(string: best.url) {
            return url
        }
        if let original = item.thumbnailOriginalURL, let url = URL(string: original) {
            return url
        }
        return nil
    }

    private static func bestJPEGThumbnail(from thumbnails: [ThumbnailDTO]) -> ThumbnailDTO? {
        guard !thumbnails.isEmpty else { return nil }
        let jpegs = thumbnails.filter { thumbnail in
            (thumbnail.imageFormat ?? "").caseInsensitiveCompare("JPEG") == .orderedSame
        }
        let candidates = jpegs.isEmpty ? thumbnails : jpegs
        return candidates.min { lhs, rhs in
            score(for: lhs) < score(for: rhs)
        }
    }

    private static func score(for thumbnail: ThumbnailDTO) -> Int {
        let width = thumbnail.maxWidth ?? Int.max
        return abs(width - preferredThumbnailWidth)
    }
}
