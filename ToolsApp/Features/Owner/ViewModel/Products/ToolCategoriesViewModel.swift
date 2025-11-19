import Combine
import SwiftUI

@MainActor
final class ToolCategoriesViewModel: ObservableObject {

    @Published var categories: [ToolCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var currentPage: Int = 0
    @Published var totalPages: Int = 1
    @Published var pageSize: Int = 10

    func fetchCategories() async {
        guard currentPage < totalPages else { return }
        isLoading = true
        errorMessage = nil

        let request = APIRequest(
            path:
                "/tools/tool-categories?page=\(currentPage)&size=\(pageSize)&sortBy=name&sortDirection=ASC",
            method: .GET
        )

        do {
            let response: ToolCategoryResponse = try await APIClient.shared
                .send(request, responseType: ToolCategoryResponse.self)
            categories.append(contentsOf: response.data.content)
            totalPages = response.data.totalPages
            currentPage += 1
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createCategory(name: String, description: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        let body = CreateToolCategoryRequest(
            name: name,
            description: description
        )
        let request = APIRequest(
            path: "/tools/tool-categories/create",
            method: .POST,
            body: body
        )

        do {
            let response: CreateToolCategoryResponse =
                try await APIClient.shared.send(
                    request,
                    responseType: CreateToolCategoryResponse.self
                )
            categories.append(response.data)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateCategory(id: Int, name: String, description: String) async
        -> Bool
    {
        isLoading = true
        errorMessage = nil

        let body = ["name": name, "description": description]
        let request = APIRequest(
            path: "/tools/tool-categories/\(id)",
            method: .PUT,
            body: body
        )

        do {
            let response: UpdateToolCategoryResponse =
                try await APIClient.shared.send(
                    request,
                    responseType: UpdateToolCategoryResponse.self
                )

            if let index = categories.firstIndex(where: { $0.id == id }) {
                categories[index] = response.data
            }

            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

