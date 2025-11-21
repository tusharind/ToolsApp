import Combine
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
                categorySearchText = categorySearchText.trimmingCharacters(
                    in: .whitespaces
                )
            }
        }
    }
    @Published var categories: [Category] = []
    @Published var isCategoryLoading: Bool = false

    @Published var name: String = ""
    @Published var description: String = ""
    @Published var price: String = ""
    @Published var rewardPts: String = ""

    @Published var nameTouched: Bool = false
    @Published var descriptionTouched: Bool = false
    @Published var priceTouched: Bool = false
    @Published var rewardTouched: Bool = false
    @Published var categoryTouched: Bool = false

    @Published var isSubmitting: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

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
            }
        }
        await fetchTask?.value
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

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var trimmedDescription: String {
        description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var trimmedPrice: String {
        price.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var trimmedReward: String {
        rewardPts.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nameError: String? {
        let regex = "^[A-Za-z ]+$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        if trimmedName.isEmpty { return "Name cannot be empty" }
        if !test.evaluate(with: trimmedName) {
            return "Name can contain letters and spaces only"
        }
        return nil
    }

    var descriptionError: String? {
        if trimmedDescription.isEmpty { return "Description cannot be empty" }
        return nil
    }

    var priceError: String? {
        guard let value = Double(trimmedPrice), value > 0 else {
            return "Enter a valid price"
        }
        return nil
    }

    var rewardError: String? {
        guard let value = Int(trimmedReward), value >= 0 else {
            return "Enter valid reward points"
        }
        return nil
    }

    var categoryError: String? {
        selectedCategoryId == nil ? "Please select a category" : nil
    }

    var isFormValid: Bool {
        nameError == nil && descriptionError == nil && priceError == nil
            && rewardError == nil && categoryError == nil
    }

    func createProduct() async {
        guard isFormValid else {
            alertMessage = "Please fix the errors in the form."
            showAlert = true
            return
        }

        guard let priceValue = Double(trimmedPrice),
            let rewardValue = Int(trimmedReward),
            let catId = selectedCategoryId
        else { return }

        let newProduct = CreateProductRequest(
            name: trimmedName,
            prodDescription: trimmedDescription,
            price: priceValue,
            rewardPts: rewardValue,
            categoryId: catId
        )

        isSubmitting = true
        defer { isSubmitting = false }

        let success = await addProduct(newProduct)
        alertMessage =
            success
            ? "Product created successfully!"
            : errorMessage ?? "Something went wrong."
        showAlert = true
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
            return false
        }
    }

    func editProduct(id: Int, _ updatedProduct: UpdateProductRequest) async
        -> Bool
    {
        isLoading = true
        defer { isLoading = false }

        do {
            let updated = try await repository.updateProduct(
                id: id,
                updatedProduct: updatedProduct
            )
            if let index = products.firstIndex(where: { $0.id == updated.id }) {
                products[index] = updated
            } else {
                products.append(updated)
            }
            return true
        } catch {
            errorMessage =
                "Failed to update product: \(error.localizedDescription)"
            return false
        }
    }

    func deleteProduct(id: Int) async {
        isLoading = true
        defer { isLoading = false }

        do {
            products.removeAll { $0.id == id }
            let _ = try await repository.deactivateProduct(id: id)
        } catch {
            errorMessage =
                "Failed to deactivate product: \(error.localizedDescription)"
            await fetchProducts(page: currentPage)
        }
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
                path: "https://example.com/owner/uploadImage/\(productId)",
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
            await fetchProducts()
        } catch {
            uploadMessage = "Upload failed: \(error.localizedDescription)"
        }
    }
}
