import Foundation

protocol FactoryRepositoryProtocol {
    func fetchFactories(
        page: Int,
        size: Int,
        searchText: String?,
        city: String?,
        sortBy: SortBy,
        sortDirection: SortDirection
    ) async throws -> APIResponse<FactoryListResponse>

    func createFactory(_ request: CreateFactoryRequest) async throws -> APIResponse<CreateFactoryResponse>

    func toggleFactoryStatus(id: Int) async throws -> ToggleResponse<EmptyResponse>

    func fetchAllManagers() async throws -> APIResponse<ManagerListResponse>

    func searchManagers(_ query: String) async throws -> APIResponse<ManagerListResponse>
}

final class FactoryRepository: FactoryRepositoryProtocol {
    private let client = APIClient.shared

    func fetchFactories(
        page: Int,
        size: Int,
        searchText: String?,
        city: String?,
        sortBy: SortBy,
        sortDirection: SortDirection
    ) async throws -> APIResponse<FactoryListResponse> {

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)"),
            URLQueryItem(name: "sortBy", value: sortBy.rawValue),
            URLQueryItem(name: "sortDirection", value: sortDirection.rawValue)
        ]

        if let searchText, !searchText.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: searchText))
        }

        if let city {
            queryItems.append(URLQueryItem(name: "city", value: city))
        }

        let queryString = queryItems
            .map { "\($0.name)=\($0.value ?? "")" }
            .joined(separator: "&")

        let path: String
        if !(searchText ?? "").isEmpty {
            path = "/owner/factories/search?\(queryString)"
        } else if city != nil {
            path = "/owner/factories/filter?\(queryString)"
        } else {
            path = "/owner/factories?\(queryString)"
        }

        let request = APIRequest(path: path, method: .GET)
        return try await client.send(request, responseType: APIResponse<FactoryListResponse>.self)
    }

    func createFactory(_ factoryRequest: CreateFactoryRequest) async throws -> APIResponse<CreateFactoryResponse> {
        let request = APIRequest(path: "/owner/createFactory", method: .POST, body: factoryRequest)
        return try await client.send(request, responseType: APIResponse<CreateFactoryResponse>.self)
    }

    func toggleFactoryStatus(id: Int) async throws -> ToggleResponse<EmptyResponse> {
        let request = APIRequest(path: "/owner/factory/\(id)/toggle-status", method: .PUT)
        return try await client.send(request, responseType: ToggleResponse<EmptyResponse>.self)
    }

    func fetchAllManagers() async throws -> APIResponse<ManagerListResponse> {
        let request = APIRequest(path: "/owner/managers/", method: .GET)
        return try await client.send(request, responseType: APIResponse<ManagerListResponse>.self)
    }

    func searchManagers(_ query: String) async throws -> APIResponse<ManagerListResponse> {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let request = APIRequest(path: "/owner/managers/?search/\(encoded)", method: .GET)
        return try await client.send(request, responseType: APIResponse<ManagerListResponse>.self)
    }
}
