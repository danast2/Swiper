//
//  CardModel.swift
//  Swiper
//
//  Created by Даниил Дементьев on 14.03.2026.
//

import Foundation
import SwiftUI

struct Card: Identifiable, Hashable {
    let id: Int
    let title: String
    let color: Color
}
