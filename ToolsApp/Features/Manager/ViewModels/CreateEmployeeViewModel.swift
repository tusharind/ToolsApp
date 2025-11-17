import SwiftUI

@MainActor
final class CreateEmployeeViewModel: ObservableObject {

    @Published var username = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var role = "WORKER"
    @Published var bayId: Int?

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    let roles = ["MANAGER", "CHIEF_SUPERVISOR", "WORKER"]

    private func validateInputs() -> Bool {

        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Username cannot be empty."
            return false
        }
        if username.rangeOfCharacter(from: .decimalDigits) != nil {
            errorMessage = "Username cannot contain numbers."
            return false
        }

        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email address."
            return false
        }

        if !isValidPhone(phone) {
            errorMessage =
                "Phone number must contain only digits and be at least 8 digits long."
            return false
        }

        if bayId == nil {
            errorMessage = "Please select a Bay ID."
            return false
        }

        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = #"^\S+@\S+\.\S+$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(
            with: email
        )
    }

    private func isValidPhone(_ phone: String) -> Bool {
        let digitsOnly = CharacterSet.decimalDigits.isSuperset(
            of: CharacterSet(charactersIn: phone)
        )
        return digitsOnly && phone.count >= 8
    }

    func createEmployee() async {
        guard validateInputs() else { return }

        guard let bayId = bayId else {
            errorMessage = "Bay ID is required."
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        let body = CreateEmployeeRequest(
            username: username,
            email: email,
            phone: phone,
            role: role,
            bayId: bayId
        )

        do {
            let request = APIRequest(
                path: "/manager/createEmployee",
                method: .POST,
                body: body
            )

            let response: GenericResponse = try await APIClient.shared.send(
                request,
                responseType: GenericResponse.self
            )
            successMessage = response.message
            clearFields()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func clearFields() {
        username = ""
        email = ""
        phone = ""
        role = "WORKER"
        bayId = nil
    }
}
