import SwiftUI

final class AuthInterceptor {
    static let shared = AuthInterceptor()
    private init() {}

    func intercept(_ request: inout URLRequest) {
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
