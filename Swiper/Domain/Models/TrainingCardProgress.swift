//
//  TrainingCardProgress.swift
//  Swiper
//

import Foundation

struct TrainingCardProgress: Codable, Hashable, Identifiable, Sendable {
    let cardID: String
    var rememberedCount: Int
    var forgottenCount: Int
    var firstRememberedAt: Date?
    var lastReviewedAt: Date?
    var nextReviewAt: Date?

    var id: String { cardID }

    init(
        cardID: String,
        rememberedCount: Int = 0,
        forgottenCount: Int = 0,
        firstRememberedAt: Date? = nil,
        lastReviewedAt: Date? = nil,
        nextReviewAt: Date? = nil
    ) {
        self.cardID = cardID
        self.rememberedCount = rememberedCount
        self.forgottenCount = forgottenCount
        self.firstRememberedAt = firstRememberedAt
        self.lastReviewedAt = lastReviewedAt
        self.nextReviewAt = nextReviewAt
    }
}
