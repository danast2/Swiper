//
//  TabView.swift
//  Swiper
//
//  Created by Даниил Дементьев on 14.03.2026.
//

import SwiftUI

struct TabBar: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                SwiperScreen()
            }
            Tab("Search", systemImage: "magnifyingglass") {}
            Tab("Create", systemImage: "plus.app") {}
            Tab("Message", systemImage: "message") {}
            Tab("Profile", systemImage: "person.crop.circle") {}
        }
    }
}
