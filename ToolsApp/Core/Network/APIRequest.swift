import SwiftUI

struct APIRequest {
    let path: String
    let method: HTTPMethod
    let parameters: [String: Any]?
    let headers: [String: String]?
    let body: Encodable?

    func buildURLRequest(with config: NetworkConfig) throws -> URLRequest {
        guard let url = URL(string: config.baseURL + path) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        return request
    }
}
