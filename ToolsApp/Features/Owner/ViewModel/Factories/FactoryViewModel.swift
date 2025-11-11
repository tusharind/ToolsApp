import SwiftUI

@MainActor
final class FactoryViewModel: ObservableObject {

    @Published var factories: [Factory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var currentPage = 0
    @Published var totalPages = 1

    @Published var searchText: String = ""
    @Published var selectedCity: String? = nil

    private let client = APIClient.shared

    func fetchFactories(page: Int = 0, size: Int = 10) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)"),
        ]

        if !searchText.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: searchText))
        }

        if let city = selectedCity {
            queryItems.append(URLQueryItem(name: "city", value: city))
        }

        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }
            .joined(separator: "&")
        let path: String
        if !searchText.isEmpty {
            path = "/owner/factories/search?\(queryString)"
        } else if selectedCity != nil {
            path = "/owner/factories/filter?\(queryString)"
        } else {
            path = "/owner/factories?\(queryString)"
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
            self.errorMessage =
                "Failed to load factories: \(error.localizedDescription)"
        }

        isLoading = false
    }

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
                errorMessage = response.message
            }
        } catch {
            errorMessage =
                "Failed to create factory: \(error.localizedDescription)"
        }

        isLoading = false
        return false
    }

    func deactivateFactory(id: Int) async -> Bool {
        isLoading = true
        errorMessage = nil

        let request = APIRequest(
            path: "/owner/deleteFactory/\(id)",
            method: .DELETE,
            parameters: nil,
            headers: nil,
            body: nil
        )

        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<EmptyResponse>.self
            )

            if response.success {

                await fetchFactories(page: 0)

                return true
            } else {
                errorMessage = response.message
                return false
            }
        } catch {
            errorMessage =
                "Failed to deactivate factory: \(error.localizedDescription)"
            return false
        }
    }
}
