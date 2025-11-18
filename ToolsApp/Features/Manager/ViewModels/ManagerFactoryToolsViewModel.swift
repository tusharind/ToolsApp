import SwiftUI

@MainActor
final class ManagerFactoryToolsViewModel: ObservableObject {
    @Published var tools: [Tools] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var page = 0
    @Published var isLastPage = false
    private let pageSize = 20

    @Published var searchText: String = ""

    var filteredTools: [Tools] {
        guard !searchText.isEmpty else { return tools }
        return tools.filter {
            $0.toolName.localizedCaseInsensitiveContains(searchText)
        }
    }

    func fetchTools(reset: Bool = false) async {
        if isLoading { return }

        if reset {
            page = 0
            isLastPage = false
            tools = []
        }

        guard !isLastPage else { return }

        isLoading = true
        errorMessage = nil

        do {
            let path = "/tools/stock/my-factory?page=\(page)&size=\(pageSize)"

            let request = APIRequest(
                path: path,
                method: .GET
            )

            let response: FactoryToolsResponse = try await APIClient.shared
                .send(request, responseType: FactoryToolsResponse.self)

            tools.append(contentsOf: response.data.content)
            isLastPage = response.data.last
            page += 1
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
