//
//  CardSwipeCallbacks.swift
//  Swiper
//

import Foundation

struct CardSwipeCallbacks<Item> {
    var onSwipeEnd: (@MainActor (Item, CardSwipeDirection) -> Void)?
    var onThresholdPassed: (@MainActor () -> Void)?
    var onNoMoreCardsLeft: (@MainActor () -> Void)?
}
