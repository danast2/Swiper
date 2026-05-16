//
//  AppEnvironment.swift
//  Swiper
//

import SwiftUI

struct AppEnvironment {
    let playlistService: PlaylistServicing
    let trainingProgressStore: TrainingProgressStoring
    let defaultPlaylistID: String
    let availablePlaylists: [PlaylistRef]

    static let live = AppEnvironment(
        playlistService: PlaylistService(),
        trainingProgressStore: UserDefaultsTrainingProgressStore(),
        defaultPlaylistID: "vplqvvlerbiu6yo2l2ed",
        availablePlaylists: [
            PlaylistRef(id: "vplq4g5wkxfnszouyazo", number: 1),
            PlaylistRef(id: "vplq7nf54mlzbc3ygiej", number: 2, coverAssetName: "playlist2"),
            PlaylistRef(id: "vplqbfddkz6ihltqww5r", number: 3, coverAssetName: "playlist3"),
            PlaylistRef(id: "vplqc76a2wmhdgzmpnab", number: 4),
            PlaylistRef(id: "vplqq7xzrobojpfkzqqj", number: 5),
            PlaylistRef(id: "vplqr6n4cdgyj7p6iqsx", number: 6),
            PlaylistRef(id: "vplqrldbvip2m3p6jtgm", number: 7, coverAssetName: "playlist7"),
            PlaylistRef(id: "vplqv5eaqbz7aqpm5e53", number: 8),
            PlaylistRef(id: "vplqz32yqvultjlgz7tp", number: 9)
        ]
    )
}

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = .live
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
