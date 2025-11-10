import Foundation

@MainActor
final class ProductsViewModel: ObservableObject {

    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 0
    @Published var totalPages = 1

    
    private let client = APIClient.shared

    private let repository = ProductRepository()

    func fetchProducts(page: Int = 0) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await repository.fetchProducts(page: page)
            products = response.data.content
            currentPage = response.data.number
            totalPages = response.data.totalPages
        } catch is CancellationError {
            print("Fetch cancelled")
        } catch {
            errorMessage =
                "Failed to load products: \(error.localizedDescription)"
            print("Error:", error)
        }
    }
    

    func addProduct(_ newProduct: CreateProductRequest) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let createdProduct = try await repository.addProduct(newProduct)
            products.append(createdProduct)
            return true
        } catch {
            errorMessage =
                "Failed to add product: \(error.localizedDescription)"
            print("Error adding product:", error)
            return false
        }
    }
}
