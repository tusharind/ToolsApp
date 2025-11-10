import SwiftUI

final class LoggerInterceptor {
    static let shared = LoggerInterceptor()
    private init() {}

    func logRequest(_ request: URLRequest) {
        print("\(request.httpMethod ?? ""): \(request.url?.absoluteString ?? "")")
    }

    func logResponse(_ data: Data, response: URLResponse?) {
        print("Response: \(String(data: data, encoding: .utf8) ?? "")")
    }
}
