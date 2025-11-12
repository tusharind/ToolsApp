import SwiftUI

@MainActor
final class ProductsViewModel: ObservableObject {

    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 0
    @Published var totalPages = 1
    @Published var searchText: String = ""
    @Published var selectedCategoryId: Int? = nil
    @Published var selectedCategoryName: String = ""
    @Published var selectedStatus: String? = nil

    // Category search
    @Published var categorySearchText: String = ""
    @Published var categories: [Category] = []
    @Published var isCategoryLoading: Bool = false

    private let client = APIClient.shared
    private let repository = ProductRepository()
    private var fetchTask: Task<Void, Never>?
    private var categoryTask: Task<Void, Never>?

    init() {
        Task { await loadAllCategories() }
    }

    // MARK: - Fetch products
    func fetchProducts(page: Int = 0) async {
        fetchTask?.cancel()
        fetchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // debounce 300ms
            guard !Task.isCancelled else { return }

            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                let response = try await repository.fetchProducts(
                    page: page,
                    size: 5,
                    search: searchText,
                    categoryId: selectedCategoryId,
                    status: selectedStatus
                )
                products = response.data.content
                currentPage = response.data.number
                totalPages = response.data.totalPages
            } catch is CancellationError {
                print("Fetch cancelled")
            } catch {
                errorMessage = "Failed to load products: \(error.localizedDescription)"
                print("Error:", error)
            }
        }
        await fetchTask?.value
    }

    // MARK: - Add product
    func addProduct(_ newProduct: CreateProductRequest) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let createdProduct = try await repository.addProduct(newProduct)
            products.append(createdProduct)
            return true
        } catch {
            errorMessage = "Failed to add product: \(error.localizedDescription)"
            print("Error adding product:", error)
            return false
        }
    }

    // MARK: - Load all categories initially
    func loadAllCategories() async {
        isCategoryLoading = true
        defer { isCategoryLoading = false }

        do {
            let results = try await repository.searchCategories(query: "")
            categories = results
        } catch {
            print("Failed to load categories:", error)
        }
    }

    // MARK: - Filter categories based on search text
    func searchCategories() async {
        categoryTask?.cancel()
        categoryTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // debounce
            guard !Task.isCancelled else { return }

            guard !categorySearchText.isEmpty else {
                await loadAllCategories()
                return
            }

            isCategoryLoading = true
            defer { isCategoryLoading = false }

            do {
                let results = try await repository.searchCategories(query: categorySearchText)
                categories = results
            } catch {
                print("Category search failed:", error)
            }
        }

        await categoryTask?.value
    }
}

// MARK: - Category Model
struct Category: Identifiable, Codable {
    let id: Int
    let categoryName: String
    let description: String?
    let productCount: Int?
}

