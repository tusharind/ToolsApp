import SwiftUI

@MainActor
final class ProductsViewModel: ObservableObject {

    @Published var products: [Product] = []
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

    @Published var selectedCategoryId: Int? = nil
    @Published var selectedCategoryName: String = ""
    @Published var selectedStatus: String? = nil

    @Published var selectedImage: UIImage?
    @Published var isShowingImagePicker = false
    @Published var isUploading = false
    @Published var uploadMessage: String?

    @Published var categorySearchText: String = "" {
        didSet {
            if categorySearchText.hasPrefix(" ") {
                categorySearchText = categorySearchText.trimmingCharacters(in: .whitespaces)
            }
        }
    }

    @Published var categories: [Category] = []
    @Published var isCategoryLoading: Bool = false

    private let client = APIClient.shared
    private let repository = ProductRepository()
    private var fetchTask: Task<Void, Never>?
    private var categoryTask: Task<Void, Never>?

    init() {
        Task { await loadAllCategories() }
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
                errorMessage =
                    "Failed to load products: \(error.localizedDescription)"
                print("Error:", error)
            }
        }
        await fetchTask?.value
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

    func searchCategories() async {
        categoryTask?.cancel()
        categoryTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            guard !categorySearchText.isEmpty else {
                await loadAllCategories()
                return
            }

            isCategoryLoading = true
            defer { isCategoryLoading = false }

            do {
                let results = try await repository.searchCategories(
                    query: categorySearchText
                )
                categories = results
            } catch {
                print("Category search failed:", error)
            }
        }

        await categoryTask?.value
    }

    func uploadImage(for productId: Int) async {
        guard let image = selectedImage else { return }

        isUploading = true
        defer { isUploading = false }

        do {
            var builder = MultipartFormDataBuilder()
            builder.addImageField(
                name: "imageFile",
                image: image,
                filename: "product.jpg"
            )
            let (body, boundary) = builder.finalize()

            let endpoint = APIEndpoint(
                path:
                    "https://herschel-hyperneurotic-hilma.ngrok-free.dev/owner/uploadImage/\(productId)",
                method: .POST,
                body: body,
                requiresAuth: true,
                contentType: "multipart/form-data; boundary=\(boundary)"
            )

            let response = try await APIService.shared.request(
                endpoint: endpoint,
                responseType: UploadProductImageResponse.self
            )

            uploadMessage = response.message
            print("Upload success:", response.message)

            await fetchProducts()
        } catch {
            uploadMessage = "Upload failed: \(error.localizedDescription)"
            print("Upload failed:", error)
        }
    }

}

