import SwiftUI

@MainActor
final class CentralInventoryViewModel: ObservableObject {
    @Published var inventoryItems: [InventoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchInventory(
        productId: Int? = nil,
        minQuantity: Int? = nil,
        maxQuantity: Int? = nil,
        sortBy: String = "id"
    ) async {
        isLoading = true
        errorMessage = nil

        let productIdPart = productId != nil ? "\(productId!)" : ""
        let minQuantityPart = minQuantity != nil ? "\(minQuantity!)" : ""
        let maxQuantityPart = maxQuantity != nil ? "\(maxQuantity!)" : ""

        let path =
            "/inventory/central-office?productId=\(productIdPart)&productName=&minQuantity=\(minQuantityPart)&maxQuantity=\(maxQuantityPart)&sortBy=\(sortBy)"

        let request = APIRequest(path: path, method: .GET)

        do {
            let response: InventoryResponse = try await APIClient.shared.send(
                request,
                responseType: InventoryResponse.self
            )

            if let content = response.data?.content {
                self.inventoryItems = content
            } else {
                self.inventoryItems = []
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
