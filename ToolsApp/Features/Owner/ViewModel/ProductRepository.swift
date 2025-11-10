import Foundation

final class ProductRepository {
    private let client = APIClient.shared

    func fetchProducts(page: Int = 0, size: Int = 10) async throws
        -> PaginatedProductsResponse
    {
        let request = APIRequest(
            path: "/owner/products?page=\(page)&size=\(size)",
            method: .GET,
            parameters: nil,
            headers: nil,
            body: nil
        )
        return try await client.send(
            request,
            responseType: PaginatedProductsResponse.self
        )
    }

    func addProduct(_ newProduct: CreateProductRequest) async throws -> Product
    {
        let request = APIRequest(
            path: "/owner/createProduct",
            method: .POST,
            parameters: nil,
            headers: nil,
            body: newProduct
        )
        let response = try await client.send(
            request,
            responseType: APIResponse<Product>.self
        )
        return response.data!
    }
}
