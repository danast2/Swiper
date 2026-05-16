//
//  SwipeDirection.swift
//  Swiper
//
//  Created by Даниил Дементьев on 14.03.2026.
//

import Foundation

public enum CardSwipeDirection: Sendable {
    case left, right, idle

    init (offset: CGFloat) {
        if offset > 0 {
            self = .right
        } else if offset == 0 {
            self = .idle
        } else {
            self = .left
        }
    }
}
