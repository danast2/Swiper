//
//  PlaylistService.swift
//  Swiper
//

import Foundation

protocol PlaylistServicing: Sendable {
    func fetchPlaylist(id: String) async throws -> PlaylistDTO
    func fetchCards(id: String) async throws -> [Card]
}

actor PlaylistService: PlaylistServicing {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchPlaylist(id: String) async throws -> PlaylistDTO {
        let url = try APIEndpoint.yandexPlaylist(id: id).url()

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw NetworkError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse(statusCode: -1)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(PlaylistDTO.self, from: data)
        } catch {
            #if DEBUG
            printDecodingDebug(
                playlistID: id,
                statusCode: httpResponse.statusCode,
                url: url,
                data: data,
                error: error
            )
            #endif
            throw NetworkError.decodingFailed(error)
        }
    }

    func fetchCards(id: String) async throws -> [Card] {
        let playlist = try await fetchPlaylist(id: id)
        return CardMapper.map(playlist)
    }

    #if DEBUG
    private func printDecodingDebug(
        playlistID: String,
        statusCode: Int,
        url: URL,
        data: Data,
        error: Error
    ) {
        let details = decodingDetails(for: error)
        let bodyPrefix = String(bytes: data.prefix(2_048), encoding: .utf8) ?? "<non-UTF8 body>"

        print(
            """
            Playlist decode failed
            playlistID: \(playlistID)
            statusCode: \(statusCode)
            url: \(url.absoluteString)
            codingPath: \(details.codingPath)
            debugDescription: \(details.debugDescription)
            bodyPrefix: \(bodyPrefix)
            """
        )
    }

    private func decodingDetails(
        for error: Error
    ) -> (codingPath: String, debugDescription: String) {
        switch error {
        case DecodingError.dataCorrupted(let context):
            return details(from: context)
        case DecodingError.keyNotFound(_, let context):
            return details(from: context)
        case DecodingError.typeMismatch(_, let context):
            return details(from: context)
        case DecodingError.valueNotFound(_, let context):
            return details(from: context)
        default:
            return (codingPath: "<unknown>", debugDescription: error.localizedDescription)
        }
    }

    private func details(from context: DecodingError.Context) -> (
        codingPath: String,
        debugDescription: String
    ) {
        (codingPath: format(codingPath: context.codingPath),
         debugDescription: context.debugDescription)
    }

    private func format(codingPath: [CodingKey]) -> String {
        guard !codingPath.isEmpty else { return "<root>" }
        return codingPath.map { $0.stringValue }.joined(separator: ".")
    }
    #endif
}
