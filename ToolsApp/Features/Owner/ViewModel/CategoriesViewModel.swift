import SwiftUI
import Combine

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published var categories: [CategoryName] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var page: Int = 0
    @Published var hasMorePages: Bool = true
    
    private let pageSize = 10
    
    func fetchCategories(reset: Bool = false) async {
        guard !isLoading else { return }
        if reset {
            page = 0
            hasMorePages = true
            categories.removeAll()
        }
        guard hasMorePages else { return }
        
        isLoading = true
        errorMessage = nil
        
        let queryItems: [String: Any] = [
            "page": page,
            "size": pageSize,
            "sortBy": "categoryName",
            "sortDirection": "ASC"
        ]
        
        let path = "/product/categories/"
        let request = APIRequest(path: path, method: .GET, parameters: queryItems)
        
        do {
            let response: APIResponse<CategoriesResponseData> = try await APIClient.shared.send(request, responseType: APIResponse<CategoriesResponseData>.self)
            
            if let data = response.data {
                categories.append(contentsOf: data.content)
                hasMorePages = !data.last
                page += 1
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func addCategory(name: String, description: String) async -> Bool {
        let body = ["categoryName": name, "description": description]
        let request = APIRequest(path: "/product/categories/createCategory", method: .POST,  headers: nil ,body: body)
        
        do {
            let response: APIResponse<EmptyResponse> = try await APIClient.shared.send(request, responseType: APIResponse<EmptyResponse>.self)
            if response.success {
                await fetchCategories(reset: true)
                return true
            } else {
                errorMessage = response.message
                return false
            }
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

