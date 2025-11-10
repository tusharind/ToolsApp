import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var role: UserRole? = nil
    @Published var token: String? = nil
    
    func setUserSession(token: String, role: UserRole) {
        self.token = token
        self.role = role
        self.isAuthenticated = true
        UserDefaults.standard.set(token, forKey: "auth_token")
        UserDefaults.standard.set(role.rawValue, forKey: "user_role")
    }
    
    func logout() {
        self.token = nil
        self.role = nil
        self.isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "user_role")
    }
}

