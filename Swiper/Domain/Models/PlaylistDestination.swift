//
//  PlaylistDestination.swift
//  Swiper
//

import Foundation

struct PlaylistDestination: Hashable, Sendable {
    let playlist: PlaylistRef
}

struct CardDestination: Hashable, Sendable {
    let playlist: PlaylistRef
    let cardID: String
}
