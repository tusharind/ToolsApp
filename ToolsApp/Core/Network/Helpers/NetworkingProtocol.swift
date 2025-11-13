import Foundation

protocol NetworkingProtocol {
    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type)
        async
        throws -> T
}

@MainActor
final class APIService: NetworkingProtocol {
    static let shared = APIService()
    private init() {}

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let request = try buildRequest(from: endpoint)
        let (data, response) = try await URLSession.shared.data(for: request)

        try validateResponse(data: data, response: response)

        return try decodeResponse(data: data, to: responseType)
    }

    private func buildRequest(from endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        request.allHTTPHeaderFields = endpoint.headers ?? [:]

        if let customContentType = endpoint.contentType {
            request.setValue(
                customContentType,
                forHTTPHeaderField: "Content-Type"
            )
        } else {
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
        }

        if request.value(forHTTPHeaderField: "Accept") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        if endpoint.requiresAuth {
            guard
                let token = AppState.shared.readFromKeychain(
                    forKey: "auth_token"
                )
            else {
                throw APIError.unauthorized
            }
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }

        return request
    }

    private func validateResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            default:
                throw APIError.serverError(
                    message: "HTTP \(httpResponse.statusCode)"
                )
            }

            let message =
                String(data: data, encoding: .utf8) ?? "Unknown server error"
            print("Server Error \(httpResponse.statusCode):", message)
            throw APIError.serverError(message: message)
        }
    }

    private func decodeResponse<T: Decodable>(data: Data, to type: T.Type)
        throws -> T
    {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error:", error)
            throw APIError.decodingError
        }
    }
}

struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: Data?
    let requiresAuth: Bool
    let contentType: String?

    init(
        path: String,
        method: HTTPMethod = .GET,
        headers: [String: String]? = nil,
        body: Data? = nil,
        requiresAuth: Bool = false,
        contentType: String? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
        self.requiresAuth = requiresAuth
        self.contentType = contentType
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case unauthorized
    case notFound
    case invalidData
    case serverError(message: String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid request URL."
        case .invalidResponse: return "Invalid response from server."
        case .decodingError: return "Failed to parse response data."
        case .unauthorized: return "Unauthorized request."
        case .notFound: return "Resource not found."
        case .serverError(let message): return message
        case .unknown: return "An unknown error occurred."
        case .invalidData:
            return "Data is invalid"
        }
    }
}
