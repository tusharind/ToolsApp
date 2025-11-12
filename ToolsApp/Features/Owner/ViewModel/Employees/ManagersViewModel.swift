import SwiftUI

@MainActor
final class ManagersViewModel: ObservableObject {
    @Published var managers: [Manager] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var currentPage = 0
    @Published var totalPages = 1

    private let client = APIClient.shared

    func createManager(username: String, email: String, phone: String) async {
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
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func fetchManagers(search: String? = nil, page: Int = 0, size: Int = 20)
        async
    {
        isLoading = true
        errorMessage = nil

        var query = "?page=\(page)&size=\(size)"
        if let search = search, !search.isEmpty {
            query += "&search=\(search)"
        }

        let request = APIRequest(
            path: "/owner/managers/\(query)",
            method: .GET,
            parameters: nil,
            headers: nil,
            body: nil
        )

        do {
            let response: PaginatedManagersResponse = try await client.send(
                request,
                responseType: PaginatedManagersResponse.self
            )
            managers = response.data?.content ?? []
            totalPages = response.data?.totalPages ?? 1
            currentPage = page
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
