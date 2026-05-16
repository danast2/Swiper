//
//  SwiperApp.swift
//  Swiper
//

import SwiftUI

@main
struct SwiperApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(\.appEnvironment, .live)
        }
    }
}
