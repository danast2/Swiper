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
    let thumbnailOriginalURL: String?
    let thumbnails: [ThumbnailDTO]

    enum CodingKeys: String, CodingKey {
        case contentID = "content_id"
        case playerURL = "player_url"
        case title
        case description
        case thumbnailOriginalURL = "thumbnail_original_url"
        case thumbnails
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        contentID = try container.decode(String.self, forKey: .contentID)
        playerURL = try container.decode(String.self, forKey: .playerURL)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        thumbnailOriginalURL = try container.decodeIfPresent(
            String.self,
            forKey: .thumbnailOriginalURL
        )
        thumbnails = try container.decodeIfPresent(
            [ThumbnailDTO].self,
            forKey: .thumbnails
        ) ?? []
    }
}

struct ThumbnailDTO: Decodable, Sendable {
    let url: String
    let maxWidth: Int?
    let maxHeight: Int?
    let imageFormat: String?

    enum CodingKeys: String, CodingKey {
        case url
        case maxWidth = "max_width"
        case maxHeight = "max_height"
        case imageFormat = "image_format"
    }
}
