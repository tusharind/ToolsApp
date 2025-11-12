import Combine
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
    @Published var sortBy: SortBy = .createdAt
    @Published var sortDirection: SortDirection = .descending

    @Published var availableManagers: [Manager] = []
    @Published var isLoadingManagers = false
    @Published var managersErrorMessage: String?
    @Published var managerSearchText: String = ""

    private var cancellables = Set<AnyCancellable>()
    private let client = APIClient.shared

    init() {

        $searchText
            .removeDuplicates()
            .debounce(for: .seconds(1.6), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.fetchFactories(page: 0) }
            }
            .store(in: &cancellables)

        $selectedCity
            .removeDuplicates()
            .debounce(for: .seconds(1.6), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.fetchFactories(page: 0) }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest($sortBy, $sortDirection)
            .sink { [weak self] _, _ in
                Task { await self?.fetchFactories(page: 0) }
            }
            .store(in: &cancellables)

        $managerSearchText
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                Task { await self?.searchManagers(query: query) }
            }
            .store(in: &cancellables)
    }

    func fetchFactories(page: Int = 0, size: Int = 10) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)"),
            URLQueryItem(name: "sortBy", value: sortBy.rawValue),
            URLQueryItem(name: "sortDirection", value: sortDirection.rawValue),
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
                if page == 0 {
                    self.factories = data.content
                } else {
                    self.factories += data.content
                }
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

    func toggleFactoryStatus(id: Int) async -> Bool {
        isLoading = true
        errorMessage = nil

        let request = APIRequest(
            path: "/owner/factory/\(id)/toggle-status",
            method: .PUT,
            parameters: nil,
            headers: nil,
            body: nil
        )

        do {
            let response = try await client.send(
                request,
                responseType: ToggleResponse<EmptyResponse>.self
            )

            if response.success {
                await fetchFactories(page: 0)
                isLoading = false
                return true
            } else {
                errorMessage = response.message
                isLoading = false
                return false
            }

        } catch {
            errorMessage =
                "Failed to toggle factory status: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }

    func fetchAvailableManagers() async {
        guard !isLoadingManagers else { return }
        isLoadingManagers = true
        managersErrorMessage = nil

        let request = APIRequest(
            path: "/owner/managers/",
            method: .GET,
            parameters: nil,
            headers: nil,
            body: nil
        )
        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<ManagerListResponse>.self
            )
            if response.success, let data = response.data {
                self.availableManagers = data.content.filter {
                    $0.status == "ACTIVE" && $0.factoryId == nil
                }
            } else {
                self.managersErrorMessage = response.message
            }
        } catch {
            self.managersErrorMessage =
                "Failed to load managers: \(error.localizedDescription)"
        }
        isLoadingManagers = false
    }

    func searchManagers(query: String) async {
        guard !query.isEmpty else {
            await fetchAvailableManagers()
            return
        }

        isLoadingManagers = true
        managersErrorMessage = nil

        let path =
            "/owner/managers/?search/\(query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
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
                responseType: APIResponse<ManagerListResponse>.self
            )
            if response.success, let data = response.data {
                self.availableManagers = data.content.filter {
                    $0.status == "ACTIVE" && $0.factoryId == nil
                }
            } else {
                self.managersErrorMessage = response.message
            }
        } catch {
            self.managersErrorMessage =
                "Failed to search managers: \(error.localizedDescription)"
        }
        isLoadingManagers = false
    }
}
