import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repository = AuthRepository()

    func login(appState: AppState) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await repository.login(
                email: email,
                password: password
            )
            if let role = UserRole(rawValue: response.role.lowercased()) {
                appState.setUserSession(token: response.token, role: role)
            } else {
                errorMessage = "Unknown user role: \(response.role)"
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
