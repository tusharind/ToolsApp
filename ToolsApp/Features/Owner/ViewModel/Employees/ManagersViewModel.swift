import SwiftUI

@MainActor
final class ManagersViewModel: ObservableObject {
    @Published var managers: [Manager] = []
    @Published var availableManagers: [Manager] = []
    @Published var factoryManagers: [Manager] = []
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
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Prevent empty or invalid values
        guard !trimmedUsername.isEmpty else {
            errorMessage = "Username cannot be empty"
            return
        }
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Email cannot be empty"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let body = ["username": trimmedUsername, "email": trimmedEmail, "phone": trimmedPhone]
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
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearchText.isEmpty {
            query += "&search=\(trimmedSearchText)"
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
            factoryManagers = managers.filter({$0.factoryId != nil})
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchAvailableManagers(page: Int = 0, size: Int = 20) async {
        isLoading = true
        errorMessage = nil
        
        var query = "?page=\(page)&size=\(size)"
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearchText.isEmpty {
            query += "&search=\(trimmedSearchText)"
        }
        
        let request = APIRequest(
            path: "/owner/managers/available",
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
            availableManagers = response.data?.content ?? []
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
    
    func deleteManager(id: Int) async {
        let request = APIRequest(
            path: "/owner/managers/\(id)",
            method: .DELETE
        )
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<EmptyData>.self
            )
            
            if response.success {
       
                await fetchManagers()
            } else {
    
                DispatchQueue.main.async {
                    self.errorMessage = response.message
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

}

