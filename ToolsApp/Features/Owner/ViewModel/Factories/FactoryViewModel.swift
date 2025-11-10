import SwiftUI

@MainActor
final class FactoryViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var factories: [Factory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var currentPage = 0
    @Published var totalPages = 1

    // Search & filter
    @Published var searchText: String = ""
    @Published var selectedStatus: String? = nil
    @Published var selectedCity: String? = nil

    private let client = APIClient.shared

    // MARK: - Fetch Factories (Paginated + Optional Search & Filter)
    func fetchFactories(page: Int = 0, size: Int = 10) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        // Determine if we need to call search API or default API
        let useSearchAPI = !searchText.isEmpty || selectedStatus != nil || selectedCity != nil
        var path = ""

        if useSearchAPI {
            var queryItems = [URLQueryItem(name: "page", value: "\(page)"),
                              URLQueryItem(name: "size", value: "\(size)")]
            if !searchText.isEmpty {
                queryItems.append(URLQueryItem(name: "name", value: searchText))
            }
            if let status = selectedStatus { queryItems.append(URLQueryItem(name: "status", value: status)) }
            if let city = selectedCity { queryItems.append(URLQueryItem(name: "city", value: city)) }

            let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
            path = "/owner/factories/search?\(queryString)"
        } else {
            path = "/owner/factories?page=\(page)&size=\(size)"
        }

        let request = APIRequest(
            path: path,
            method: .GET,
            parameters: nil,
            headers: nil,
            body: nil
        )

        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<FactoryListResponse>.self
            )

            if response.success, let data = response.data {
                self.factories = data.content
                self.totalPages = data.totalPages ?? 1
                self.currentPage = data.number ?? 0
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = "Failed to load factories: \(error.localizedDescription)"
        }

        isLoading = false
    }


    // MARK: - Create a new factory
    func createFactory(_ factoryRequest: CreateFactoryRequest) async -> Bool {
        isLoading = true
        errorMessage = nil

        let request = APIRequest(
            path: "/owner/createFactory",
            method: .POST,
            parameters: nil,
            headers: nil,
            body: factoryRequest
        )

        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<CreateFactoryResponse>.self
            )

            if response.success {
                await fetchFactories(page: 0) // refresh list
                isLoading = false
                return true
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = "Failed to create factory: \(error.localizedDescription)"
        }

        isLoading = false
        return false
    }
}

