import SwiftUI

@MainActor
final class AuthInterceptor {
    static let shared = AuthInterceptor()
    private init() {}

    func intercept(_ request: inout URLRequest) {
        // Directly get the current token from AppState singleton
        if let token = AppState.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}

