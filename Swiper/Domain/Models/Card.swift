//
//  Card.swift
//  Swiper
//

import Foundation
import SwiftUI

struct Card: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let color: Color
    let videoURL: URL?
    let thumbnailURL: URL?

    init(
        id: String,
        title: String,
        description: String = "",
        color: Color,
        videoURL: URL? = nil,
        thumbnailURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.color = color
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
    }
}
