import Combine
import SwiftUI

@MainActor
final class FactoryViewModel: ObservableObject {

    @Published var factories: [Factory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var currentPage = 0
    @Published var totalPages = 1

    @Published var searchText: String = "" {
        didSet {
            if searchText.hasPrefix(" ") {
                searchText = searchText.trimmingCharacters(in: .whitespaces)
            }
        }
    }

    @Published var selectedCity: String? = nil
    @Published var sortBy: SortBy = .createdAt
    @Published var sortDirection: SortDirection = .descending

    @Published var availableManagers: [Manager] = []
    @Published var isLoadingManagers = false
    @Published var managersErrorMessage: String?
    @Published var managerSearchText: String = "" {
        didSet {
            if managerSearchText.hasPrefix(" ") {
                managerSearchText = managerSearchText.trimmingCharacters(
                    in: .whitespaces
                )
            }
        }
    }

    @Published var name: String = ""
    @Published var city: String = ""
    @Published var address: String = ""
    @Published var selectedManagerId: Int? = nil

    @Published var nameTouched = false
    @Published var cityTouched = false
    @Published var addressTouched = false
    @Published var managerTouched = false

    @Published var isSubmitting = false
    @Published var showAlert = false
    @Published var alertMessage = ""

    private var cancellables = Set<AnyCancellable>()
    private let client = APIClient.shared

    init() {
        setupBindings()
    }

    private func setupBindings() {

        $searchText
            .removeDuplicates()
            .debounce(for: .seconds(1.6), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { await self?.handleFactorySearch() }
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
                Task { await self?.handleManagerSearch(query: query) }
            }
            .store(in: &cancellables)
    }

    private func handleFactorySearch() async {
        guard searchText.count >= 2 || searchText.isEmpty else {
            errorMessage = "Enter at least 2 characters to search factories."
            return
        }
        await fetchFactories(page: 0)
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

        let request = APIRequest(path: path, method: .GET)

        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<FactoryListResponse>.self
            )
            if response.success, let data = response.data {
                if page == 0 {
                    factories = data.content
                } else {
                    factories += data.content
                }
                totalPages = data.totalPages ?? 1
                currentPage = data.number ?? 0
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage =
                "Failed to load factories: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func toggleFactoryStatus(id: Int) async -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        errorMessage = nil

        let request = APIRequest(
            path: "/owner/factory/\(id)/toggle-status",
            method: .PUT
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
            }
        } catch {
            errorMessage =
                "Failed to toggle factory status: \(error.localizedDescription)"
        }

        isLoading = false
        return false
    }

    private func handleManagerSearch(query: String) async {
        guard query.count >= 2 || query.isEmpty else {
            managersErrorMessage =
                "Enter at least 2 characters to search managers."
            return
        }
        await searchManagers(query: query)
    }

    func fetchAvailableManagers() async {
        guard !isLoadingManagers else { return }
        isLoadingManagers = true
        managersErrorMessage = nil

        let request = APIRequest(path: "/owner/managers/", method: .GET)
        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<ManagerListResponse>.self
            )
            if response.success, let data = response.data {
                availableManagers = data.content.filter {
                    $0.status == "ACTIVE" && $0.factoryId == nil
                }
            } else {
                managersErrorMessage = response.message
            }
        } catch {
            managersErrorMessage =
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

        let encoded =
            query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            ?? ""
        let path = "/owner/managers/?search/\(encoded)"
        let request = APIRequest(path: path, method: .GET)

        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<ManagerListResponse>.self
            )
            if response.success, let data = response.data {
                availableManagers = data.content.filter {
                    $0.status == "ACTIVE" && $0.factoryId == nil
                }
            } else {
                managersErrorMessage = response.message
            }
        } catch {
            managersErrorMessage =
                "Failed to search managers: \(error.localizedDescription)"
        }

        isLoadingManagers = false
    }

    func updateFactoryManager(factoryId: Int, managerId: Int) async -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        errorMessage = nil

        let request = APIRequest(
            path: "/owner/factories/\(factoryId)/manager",
            method: .PATCH,
            body: ["managerId": managerId]
        )

        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<EmptyResponse>.self
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
                "Failed to update manager: \(error.localizedDescription)"
        }

        isLoading = false
        return false
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var trimmedCity: String {
        city.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var trimmedAddress: String {
        address.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nameError: String? {
        let regex = "^[A-Za-z ]+$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        if trimmedName.isEmpty { return "Name cannot be empty" }
        if !test.evaluate(with: trimmedName) {
            return "Name can contain letters and spaces only"
        }
        return nil
    }

    var cityError: String? {
        let regex = "^[A-Za-z ]+$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        if trimmedCity.isEmpty { return "City cannot be empty" }
        if !test.evaluate(with: trimmedCity) {
            return "City can contain letters and spaces only"
        }
        return nil
    }

    var addressError: String? {
        let regex = "^[A-Za-z0-9 ,.-]+$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        if trimmedAddress.isEmpty { return "Address cannot be empty" }
        if !test.evaluate(with: trimmedAddress) {
            return
                "Address can contain letters, numbers, commas, periods, and hyphens"
        }
        return nil
    }

    var managerError: String? {
        selectedManagerId == nil ? "Please select a manager" : nil
    }

    var isFormValid: Bool {
        nameError == nil && cityError == nil && addressError == nil
            && managerError == nil
    }

    func createFactory() async -> Bool {
        guard isFormValid, let managerId = selectedManagerId else {
            alertMessage = "Please fill in all fields correctly"
            showAlert = true
            return false
        }

        isSubmitting = true
        defer { isSubmitting = false }

        let request = CreateFactoryRequest(
            name: trimmedName,
            city: trimmedCity,
            address: trimmedAddress,
            plantHeadId: managerId
        )

        do {
            let success = await attemptCreateFactory(request: request)
            alertMessage =
                success
                ? "Factory created successfully!"
                : "Failed to create factory. Please try again."
            showAlert = true
            return success
        }
    }

    private func attemptCreateFactory(request: CreateFactoryRequest) async
        -> Bool
    {
        let apiRequest = APIRequest(
            path: "/owner/createFactory",
            method: .POST,
            body: request
        )
        do {
            let response = try await client.send(
                apiRequest,
                responseType: APIResponse<CreateFactoryResponse>.self
            )
            if response.success {
                await fetchFactories(page: 0)
                return true
            } else {
                alertMessage = response.message
            }
        } catch {
            alertMessage =
                "Failed to create factory: \(error.localizedDescription)"
        }
        return false
    }
}
