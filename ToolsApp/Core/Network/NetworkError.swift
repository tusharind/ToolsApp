import SwiftUI

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noInternet
    case unauthorized
    case decodingFailed
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .noInternet: return "No internet connection."
        case .unauthorized: return "Unauthorized access."
        case .decodingFailed: return "Failed to parse response."
        case .serverError(let message): return message
        }
    }
}
