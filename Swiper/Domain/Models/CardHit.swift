//
//  CardHit.swift
//  Swiper
//

import Foundation

struct CardHit: Identifiable, Hashable, Sendable {
    let card: Card
    let playlist: PlaylistRef

    var id: String { "\(playlist.id)/\(card.id)" }
}
