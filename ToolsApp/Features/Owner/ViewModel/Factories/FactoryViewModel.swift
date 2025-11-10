import SwiftUI

@MainActor
final class FactoryViewModel: ObservableObject {
    @Published var factories: [Factory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var currentPage = 0
    @Published var totalPages = 1

    private let client = APIClient.shared

    // MARK: - Fetch Factories (Paginated)
    func fetchFactories(page: Int = 0, size: Int = 10) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let request = APIRequest(
            path: "/owner/factories?page=\(page)&size=\(size)",
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

            if let data = response.data {
                self.factories = data.content
                self.totalPages = data.totalPages ?? 1
                self.currentPage = data.number ?? 0
            } else {
                self.errorMessage = "No data found."
            }
        } catch {
            self.errorMessage =
                "Failed to load factories: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Create New Factory
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
                await fetchFactories(page: 0)
                isLoading = false
                return true
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage =
                "Failed to create factory: \(error.localizedDescription)"
        }

        isLoading = false
        return false
    }

}
