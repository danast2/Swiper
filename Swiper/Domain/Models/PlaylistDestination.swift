//
//  PlaylistDestination.swift
//  Swiper
//

import Foundation

struct PlaylistDestination: Hashable, Sendable {
    let playlist: PlaylistRef
    let initialCardID: String?
}
