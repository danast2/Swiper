//
//  NetworkError.swift
//  Swiper
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case badURL
    case badResponse(statusCode: Int)
    case decodingFailed(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .badURL:
            return String(localized: "error.network.badURL")
        case .badResponse(let statusCode):
            return String(localized: "error.network.badResponse \(statusCode)")
        case .decodingFailed:
            return String(localized: "error.network.decodingFailed")
        case .transport:
            return String(localized: "error.network.transport")
        }
    }
}
