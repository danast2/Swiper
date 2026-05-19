//
//  RootTabView.swift
//  Swiper
//

import SwiftUI

struct RootTabView: View {
    @Environment(\.appEnvironment) private var environment

    var body: some View {
        TabView {
            Tab("tab.home", systemImage: "house") {
                HomeScreen(
                    viewModel: HomeViewModel(
                        service: environment.playlistService,
                        playlists: environment.availablePlaylists
                    )
                )
            }
            Tab("tab.search", systemImage: "magnifyingglass") {
                SearchScreen(
                    viewModel: SearchViewModel(
                        service: environment.playlistService,
                        playlists: environment.availablePlaylists
                    )
                )
            }
            Tab("tab.training", systemImage: "graduationcap") {
                NavigationStack {
                    TrainingScreen(
                        viewModel: TrainingViewModel(
                            service: environment.playlistService,
                            playlistID: environment.defaultPlaylistID,
                            progressStore: environment.trainingProgressStore
                        )
                    )
                    .navigationTitle("tab.training")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}
