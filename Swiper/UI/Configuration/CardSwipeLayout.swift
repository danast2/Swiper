//
//  CardSwipeLayout.swift
//  Swiper
//

import Foundation
import CoreGraphics

enum CardSwipeLayout {
    static let rotationDivisor: CGFloat = 20

    static let card1YOffset: CGFloat = 50
    static let card1BaseScale: CGFloat = 0.9

    static let card2YOffset: CGFloat = 110
    static let card2YDelta: CGFloat = 60
    static let card2BaseScale: CGFloat = 0.8

    static let card3YOffset: CGFloat = 180
    static let card3YDelta: CGFloat = 70
    static let card3BaseScale: CGFloat = 0.7

    static let scaleStep: CGFloat = 0.1
    static let popAnimationDuration: Double = 0.5

    static let cardWidth: CGFloat = 380
    static let cardHeight: CGFloat = 650
    static let cardContentPadding: CGFloat = 16
    static let videoWidth: CGFloat = 350
    static let videoHeight: CGFloat = 480
    static let videoCornerRadius: CGFloat = 8
    static let cardCornerRadius: CGFloat = 10
    static let cardShadowRadius: CGFloat = 5
    static let indicatorPadding: CGFloat = 10
    static let cardContentSpacing: CGFloat = 10
    static let titleLineLimit: Int = 2
    static let descriptionMaxHeight: CGFloat = 84
    static let descriptionHorizontalPadding: CGFloat = 8
}
