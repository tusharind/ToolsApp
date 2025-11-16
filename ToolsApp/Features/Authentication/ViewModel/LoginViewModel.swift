import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = "" {
        didSet {

            if email != email.trimmingCharacters(in: .whitespacesAndNewlines) {
                email = email.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shake: CGFloat = 0

    private let repository = AuthRepository()

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(
            with: email
        )
    }

    private func validateInputs() -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            errorMessage = "Email is required."
            return false
        }

        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Please enter a valid email address."
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Password is required."
            return false
        }

        guard password.count >= 5 else {
            errorMessage = "Password must be at least 6 characters long."
            return false
        }

        email = trimmedEmail
        return true
    }

    func login(appState: AppState) async {
        guard validateInputs() else {
            shakeAnimation()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await repository.login(
                email: email,
                password: password
            )

            print("Login Response: \(response)")

            appState.setUserSession(token: response.token, role: response.role)

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func shakeAnimation() {
        let base: CGFloat = 10
        withAnimation(.default) { shake = -base }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default) { self.shake = base }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.default) { self.shake = 0 }
        }
    }
}
