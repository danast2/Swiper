//
//  SwiperScreen.swift
//  Swiper
//
//  Created by Даниил Дементьев on 14.03.2026.
//

import SwiftUI

struct SwiperScreen: View {
    // Sample data
    @State private var cards = [
        Card(id: 1, title: "Card 1", color: .red),
        Card(id: 2, title: "Card 2", color: .blue),
        Card(id: 3, title: "Card 3", color: .green),
        Card(id: 4, title: "Card 4", color: .orange),
        Card(id: 5, title: "Card 5", color: .purple)
    ]
    @State private var selectedCard: Card?
    @State private var popTrigger: CardSwipeDirection?

    var body: some View {
        VStack {
            CardSwipeView(items: $cards, selectedItem: $selectedCard, popTrigger: $popTrigger) { card, progress, direction in
                // Card content
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(card.color)

                    VStack {
                        Text(card.title)
                            .font(.largeTitle)
                            .foregroundColor(.white)

                        // Show direction indicator based on swipe
                        Text(direction == .left ? "NOPE" : "LIKE")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(direction == .left ? .red : .green)
                            .cornerRadius(10)
                            .opacity(progress)
                    }
                }
                .frame(width: 300, height: 400)
                .shadow(radius: 5)
            }
            .onSwipeEnd { card, direction in
                print("Swiped \(direction) on card: \(card.title)")
            }
            .onNoMoreCardsLeft {
                print("No more cards left!, dismiss?")
            }
        }
    }
}
