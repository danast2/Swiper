//
//  PlaylistRef.swift
//  Swiper
//

import Foundation

struct PlaylistRef: Identifiable, Hashable, Sendable {
    let id: String
    let number: Int
    let title: String
    let coverAssetName: String?

    init(id: String, number: Int, title: String, coverAssetName: String? = nil) {
        self.id = id
        self.number = number
        self.title = title
        self.coverAssetName = coverAssetName
    }
}
