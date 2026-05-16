//
//  PlaylistDTO.swift
//  Swiper
//

import Foundation

struct PlaylistDTO: Decodable, Sendable {
    let playlistItems: [PlaylistItemDTO]

    enum CodingKeys: String, CodingKey {
        case playlistItems = "playlist_items"
    }
}

struct PlaylistItemDTO: Decodable, Sendable {
    let contentID: String
    let playerURL: String
    let title: String
    let description: String?

    enum CodingKeys: String, CodingKey {
        case contentID = "content_id"
        case playerURL = "player_url"
        case title
        case description
    }
}
