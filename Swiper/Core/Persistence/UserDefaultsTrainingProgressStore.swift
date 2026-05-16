//
//  UserDefaultsTrainingProgressStore.swift
//  Swiper
//

import Foundation

protocol TrainingProgressStoring: Sendable {
    func loadProgress(playlistID: String) async -> [TrainingCardProgress]
    func saveProgress(
        _ progress: [TrainingCardProgress],
        playlistID: String,
        revision: Int
    ) async
}

actor UserDefaultsTrainingProgressStore: TrainingProgressStoring {
    private let userDefaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var latestRevisionByPlaylistID: [String: Int] = [:]

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadProgress(playlistID: String) async -> [TrainingCardProgress] {
        guard let data = userDefaults.data(forKey: key(for: playlistID)) else {
            return []
        }
        return (try? decoder.decode([TrainingCardProgress].self, from: data)) ?? []
    }

    func saveProgress(
        _ progress: [TrainingCardProgress],
        playlistID: String,
        revision: Int
    ) async {
        let latestRevision = latestRevisionByPlaylistID[playlistID] ?? 0
        guard revision >= latestRevision else { return }
        latestRevisionByPlaylistID[playlistID] = revision

        let sortedProgress = progress.sorted { $0.cardID < $1.cardID }
        guard let data = try? encoder.encode(sortedProgress) else { return }
        userDefaults.set(data, forKey: key(for: playlistID))
    }

    private func key(for playlistID: String) -> String {
        "trainingProgress.v1.\(playlistID)"
    }
}
