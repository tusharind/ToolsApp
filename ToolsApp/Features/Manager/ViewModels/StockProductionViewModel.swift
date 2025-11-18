import SwiftUI

@MainActor
final class StockProductionViewModel: ObservableObject {

    @Published var products: [Product] = []
    @Published var selectedProduct: Product? = nil

    @Published var searchText: String = "" {
        didSet {
            if searchText.hasPrefix(" ") {
                searchText = searchText.trimmingCharacters(in: .whitespaces)
            }
        }
    }

    @Published var quantity: String = ""

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    @Published var currentPage: Int = 0
    @Published var totalPages: Int = 1

    private let repository = ProductRepository()
    private var fetchTask: Task<Void, Never>?

    init() {
        Task { await fetchProducts() }
    }

    func fetchProducts(page: Int = 0) async {
        fetchTask?.cancel()
        fetchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                let response = try await repository.fetchProducts(
                    page: page,
                    size: 50,
                    search: searchText,
                    categoryId: nil,
                    status: nil
                )

                products = response.data.content
                currentPage = response.data.number
                totalPages = response.data.totalPages
            } catch is CancellationError {
                print("Fetch cancelled")
            } catch {
                errorMessage =
                    "Failed to load products: \(error.localizedDescription)"
                print("Error fetching products:", error)
            }
        }
        await fetchTask?.value
    }

    func addStock() async {
        guard let product = selectedProduct,
            let quantityInt = Int(quantity), quantityInt > 0
        else {
            errorMessage =
                "Select a valid product and enter a positive quantity"
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let urlPath = "/inventory/factories/stock/production"
            let requestBody = StockProductionRequest(
                productId: product.id,
                quantity: quantityInt
            )
            let apiRequest = APIRequest(
                path: urlPath,
                method: .POST,
                body: requestBody
            )

            let response = try await APIClient.shared.send(
                apiRequest,
                responseType: StockProductionResponse.self
            )

            if response.success {
                successMessage = response.message
                quantity = ""
                selectedProduct = nil
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func searchProductsDebounced() {
        fetchTask?.cancel()
        fetchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await fetchProducts()
        }
    }

    func loadNextPage() async {
        guard currentPage + 1 < totalPages else { return }
        await fetchProducts(page: currentPage + 1)
    }

    func loadPreviousPage() async {
        guard currentPage > 0 else { return }
        await fetchProducts(page: currentPage - 1)
    }
}
