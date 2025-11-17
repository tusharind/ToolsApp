import SwiftUI

struct APIRequest {
    let path: String
    let method: HTTPMethod
    let parameters: [String: Any]?
    let headers: [String: String]?
    let body: Encodable?
    let contentType: String?
    
    init(path: String, method: HTTPMethod, parameters: [String : Any]? = nil, headers: [String : String]? = nil, body: Encodable? = nil, contentType: String? = nil) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.body = body
        self.contentType = contentType
    }
    
    func buildURLRequest(with config: NetworkConfig) throws -> URLRequest {
        
        var urlComponents = URLComponents(string: config.baseURL + path)
        
        guard let url = URL(string: config.baseURL + path) else {
            throw NetworkError.invalidURL
        }
        
        if method == .GET, let parameters = parameters {
                urlComponents?.queryItems = parameters.map { key, value in
                    URLQueryItem(name: key, value: "\(value)")
                }
            }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers ?? [:]
        
        if let customContentType = contentType {
            request.setValue(customContentType, forHTTPHeaderField: "Content-Type")
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if request.value(forHTTPHeaderField: "Accept") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        return request
    }
}
