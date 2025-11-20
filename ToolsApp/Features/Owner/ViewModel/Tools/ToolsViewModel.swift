import SwiftUI

@MainActor
final class ToolsViewModel: ObservableObject {

    @Published var tools: [ToolItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText: String = "" {
        didSet {
            if searchText.hasPrefix(" ") {
                searchText = searchText.trimmingCharacters(in: .whitespaces)
            }
        }
    }

    @Published var page = 0
    @Published var isLastPage = false

    @Published var categoryId: Int?
    @Published var status: String?
    @Published var type: String?
    @Published var isExpensive: String?

    @Published var categories: [ToolCategory] = []
    @Published var selectedCategoryId: Int? = nil

    private var searchTask: Task<Void, Never>? = nil

    init() {
        fetchCategories()
        fetchTools(reset: true)
    }

    func fetchTools(reset: Bool = false) {
        if reset {
            page = 0
            isLastPage = false
            tools.removeAll()
        }

        guard !isLastPage else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let path = buildURLPath()

                let request = APIRequest(
                    path: path,
                    method: .GET,
                    parameters: nil,
                    headers: nil
                )

                let response: PaginatedResponse<ToolItem> =
                    try await APIClient.shared.send(
                        request,
                        responseType: PaginatedResponse<ToolItem>.self
                    )

                tools.append(contentsOf: response.data.content)
                isLastPage = response.data.last
                page += 1

            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    func fetchCategories() {
        Task {
            do {
                let request = APIRequest(
                    path: "/tools/tool-categories?page=0&size=50&sortBy=name",
                    method: .GET,
                    parameters: nil,
                    headers: nil
                )

                let response: PaginatedResponse<ToolCategory> =
                    try await APIClient.shared.send(
                        request,
                        responseType: PaginatedResponse<ToolCategory>.self
                    )

                self.categories = response.data.content

            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func buildURLPath() -> String {
        let category = categoryId != nil ? "\(categoryId!)" : ""
        let statusValue = status ?? ""
        let typeValue = type ?? ""
        let expensiveValue = isExpensive ?? ""
        let searchValue = searchText.isEmpty ? "" : searchText

        return
            "/tools/?page=\(page)&size=10&categoryId=\(category)&status=\(statusValue)&type=\(typeValue)&expensive=\(expensiveValue)&search=\(searchValue)"
    }

    func onSearchChanged() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            fetchTools(reset: true)
        }
    }

    func applyFilters(
        categoryId: Int?,
        status: String?,
        type: String?,
        isExpensive: String?
    ) {
        self.categoryId = categoryId
        self.status = status
        self.type = type
        self.isExpensive = isExpensive

        fetchTools(reset: true)
    }

    func selectCategory(_ id: Int?) {
        self.selectedCategoryId = id
        self.categoryId = id
        fetchTools(reset: true)
    }

    func fetchToolById(_ id: Int) async -> ToolItem? {
        do {
            let request = APIRequest(
                path: "/tools/\(id)",
                method: .GET,
                parameters: nil,
                headers: nil
            )

            let response: APIResponse<ToolItem> =
                try await APIClient.shared.send(
                    request,
                    responseType: APIResponse<ToolItem>.self
                )

            return response.data

        } catch {
            self.errorMessage = error.localizedDescription
            return nil
        }
    }

    func deleteTool(_ id: Int) {
        Task {
            do {
                let request = APIRequest(
                    path: "/tools/\(id)",
                    method: .DELETE,
                    parameters: nil,
                    headers: nil
                )

                let _: APIResponse<EmptyResponse> =
                    try await APIClient.shared.send(
                        request,
                        responseType: APIResponse<EmptyResponse>.self
                    )

                await MainActor.run {
                    tools.removeAll { $0.id == id }
                }

            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

}
