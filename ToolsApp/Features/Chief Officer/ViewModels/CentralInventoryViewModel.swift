import SwiftUI

@MainActor
final class CentralInventoryViewModel: ObservableObject {

    @Published var productId: String = ""
    @Published var minQuantity: String = ""
    @Published var maxQuantity: String = ""
    @Published var sortBy: SortOption = .id
    @Published var searchText: String = ""

    @Published var inventoryItems: [InventoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var filteredItems: [InventoryItem] {
        var items = inventoryItems

        if !searchText.isEmpty {
            items = items.filter {
                $0.productName.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortBy {
        case .id:
            items.sort { $0.productId < $1.productId }
        case .name:
            items.sort { $0.productName.lowercased() < $1.productName.lowercased() }
        case .quantity:
            items.sort { $0.quantity < $1.quantity }
        case .totalReceived:
            items.sort { $0.totalReceived < $1.totalReceived }
        }

        return items
    }

    func applyFilters() async {
        await fetchInventory(
            productId: Int(productId),
            minQuantity: Int(minQuantity),
            maxQuantity: Int(maxQuantity),
            sortBy: sortBy.rawValue
        )
    }
    
    func fetchInventory(
        productId: Int? = nil,
        minQuantity: Int? = nil,
        maxQuantity: Int? = nil,
        sortBy: String
    ) async {

        isLoading = true
        errorMessage = nil

        let path =
            "/inventory/central-office?productId=\(productId ?? 0)"
            + "&productName="
            + "&minQuantity=\(minQuantity ?? 0)"
            + "&maxQuantity=\(maxQuantity ?? 0)"
            + "&sortBy=\(sortBy)"

        do {
            let request = APIRequest(path: path, method: .GET)

            let response: InventoryResponse =
                try await APIClient.shared.send(request, responseType: InventoryResponse.self)

            self.inventoryItems = response.data?.content ?? []
            self.errorMessage = response.message

        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

