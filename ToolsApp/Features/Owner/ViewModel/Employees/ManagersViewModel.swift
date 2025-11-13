import SwiftUI

@MainActor
final class ManagersViewModel: ObservableObject {
    @Published var managers: [Manager] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var currentPage = 0
    @Published var totalPages = 1

    @Published var searchText: String = "" {
        didSet { validateSearchText() }
    }

    private let client = APIClient.shared

    private func validateSearchText() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleaned = trimmed.replacingOccurrences(
            of: #"[^A-Za-z0-9\s@._-]"#,
            with: "",
            options: .regularExpression
        )
        if cleaned != searchText {
            searchText = cleaned
        }
    }

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

    func fetchManagers(page: Int = 0, size: Int = 20) async {
        isLoading = true
        errorMessage = nil

        var query = "?page=\(page)&size=\(size)"
        if !searchText.isEmpty {
            query += "&search=\(searchText)"
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
    
    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "inactive": return .red
        case "pending": return .orange
        default: return .blue
        }
    }

    func formattedDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .short
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

