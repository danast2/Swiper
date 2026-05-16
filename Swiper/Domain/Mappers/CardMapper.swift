//
//  CardMapper.swift
//  Swiper
//

import Foundation
import SwiftUI

enum CardMapper {
    private static let formatQueryToStrip = "&format=json"

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
                videoURL: URL(string: sanitizedURL)
            )
        }
    }
}
