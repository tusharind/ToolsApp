import Security
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var role: UserRole? = nil
    @Published var token: String? = nil
    
    static let shared = AppState()

    private let tokenKey = "auth_token"
    private let roleKey = "user_role"

    func setUserSession(token: String, role: UserRole) {
        self.token = token
        self.role = role
        self.isAuthenticated = true

        saveToKeychain(value: token, forKey: tokenKey)
        saveToKeychain(value: role.rawValue, forKey: roleKey)

        UserDefaults.standard.set(true, forKey: "is_authenticated")
    }

    func logout() {
        self.token = nil
        self.role = nil
        self.isAuthenticated = false

        deleteFromKeychain(forKey: tokenKey)
        deleteFromKeychain(forKey: roleKey)

        UserDefaults.standard.removeObject(forKey: "is_authenticated")
    }

    func restoreSession() {
        if let savedToken = readFromKeychain(forKey: tokenKey),
            let savedRoleRaw = readFromKeychain(forKey: roleKey),
            let savedRole = UserRole(rawValue: savedRoleRaw)
        {
            self.token = savedToken
            self.role = savedRole
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }

    private func saveToKeychain(value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

     func readFromKeychain(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
            let data = item as? Data,
            let value = String(data: data, encoding: .utf8)
        else { return nil }
        return value
    }

    private func deleteFromKeychain(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
