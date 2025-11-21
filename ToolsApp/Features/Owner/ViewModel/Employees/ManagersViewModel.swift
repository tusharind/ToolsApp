import Combine
import SwiftUI

@MainActor
final class ManagersViewModel: ObservableObject {

    @Published var managers: [Manager] = []
    @Published var factoryManagers: [Manager] = []
    @Published var availableManagers: [Manager] = []

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didCreateSuccessfully = false

    @Published var searchText: String = "" {
        didSet { handleSearchDebounce() }
    }

    @Published var newUsername = ""
    @Published var newEmail = ""
    @Published var newPhone = ""

    @Published var currentPage = 0
    @Published var totalPages = 1

    private var searchTask: Task<Void, Never>? = nil
    private let client = APIClient.shared

    var canSubmitManagerForm: Bool {
        !newUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !newEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !newPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var usernameError: String? {
        newUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Username cannot be empty" : nil
    }

    var emailError: String? {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let valid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(
            with: newEmail
        )
        return valid ? nil : "Enter a valid email"
    }

    var phoneError: String? {
        let phoneRegex = "^[0-9]{7,15}$"
        let valid = NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(
            with: newPhone
        )
        return valid ? nil : "Enter a valid phone number"
    }

    var isFormValid: Bool {
        canSubmitManagerForm && usernameError == nil && emailError == nil
            && phoneError == nil
    }

    func createManager() async {
        let username = newUsername.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let email = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = newPhone.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isFormValid else {
            errorMessage = "Please fix validation errors before submitting"
            return
        }

        isLoading = true
        errorMessage = nil

        let body = ["username": username, "email": email, "phone": phone]
        let request = APIRequest(
            path: "/owner/managers/create",
            method: .POST,
            parameters: nil,
            headers: nil,
            body: body
        )

        do {
            let response: ManagerCreationResponse = try await client.send(
                request,
                responseType: ManagerCreationResponse.self
            )
            managers.append(response.data)
            didCreateSuccessfully = true
            resetForm()
            await fetchAvailableManagers()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func fetchManagers(page: Int = 0, size: Int = 20) async {
        await fetchManagersInternal(
            path: "/owner/managers",
            page: page,
            size: size
        ) { managers in
            factoryManagers = managers.filter { $0.factoryId != nil }
        }
    }

    func fetchAvailableManagers(page: Int = 0, size: Int = 20) async {
        await fetchManagersInternal(
            path: "/owner/managers/available",
            page: page,
            size: size
        ) { _ in }
    }

    func deleteManager(_ manager: Manager) async {
        isLoading = true
        errorMessage = nil

        let request = APIRequest(
            path: "/owner/managers/\(manager.id)",
            method: .DELETE
        )

        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<EmptyData>.self
            )
            if response.success {
                await fetchAvailableManagers()
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func fetchManagersInternal(
        path: String,
        page: Int,
        size: Int,
        updateFactory: ([Manager]) -> Void
    ) async {
        isLoading = true
        errorMessage = nil

        var query = "?page=\(page)&size=\(size)"
        let trimmedSearch = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        if !trimmedSearch.isEmpty {
            query += "&search=\(trimmedSearch)"
        }

        let request = APIRequest(path: "\(path)\(query)", method: .GET)

        do {
            let response: PaginatedManagersResponse = try await client.send(
                request,
                responseType: PaginatedManagersResponse.self
            )
            let fetchedManagers = response.data?.content ?? []
            managers = fetchedManagers
            totalPages = response.data?.totalPages ?? 1
            currentPage = page
            updateFactory(fetchedManagers)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func handleSearchDebounce() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 900_000_000)
            guard !Task.isCancelled else { return }
            await self?.fetchAvailableManagers()
        }
    }

    private func resetForm() {
        newUsername = ""
        newEmail = ""
        newPhone = ""
    }

    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "inactive": return .red
        case "pending": return .orange
        default: return .blue
        }
    }
}
