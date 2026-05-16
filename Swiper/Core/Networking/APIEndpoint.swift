//
//  APIEndpoint.swift
//  Swiper
//

import Foundation

struct APIEndpoint {
    let scheme: String
    let host: String
    let path: String
    let queryItems: [URLQueryItem]

    func url() throws -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems
        guard let url = components.url else {
            throw NetworkError.badURL
        }
        return url
    }
}

extension APIEndpoint {
    static func yandexPlaylist(id: String) -> APIEndpoint {
        APIEndpoint(
            scheme: "https",
            host: "runtime.video.cloud.yandex.net",
            path: "/player/playlist/\(id)",
            queryItems: [
                URLQueryItem(name: "autoplay", value: "0"),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "mute", value: "0")
            ]
        )
    }
}
