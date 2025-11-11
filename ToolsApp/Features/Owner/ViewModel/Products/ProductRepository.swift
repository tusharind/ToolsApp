import Foundation

final class ProductRepository {
    private let client = APIClient.shared

    func fetchProducts(page: Int = 0,
                       size: Int = 10,
                       search: String? = nil,
                       categoryId: Int? = nil,
                       status: String? = nil) async throws -> PaginatedProductsResponse
    {
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        queryItems.append(URLQueryItem(name: "size", value: "\(size)"))

        if let search = search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }

        if let categoryId = categoryId {
            queryItems.append(URLQueryItem(name: "categoryId", value: "\(categoryId)"))
        }

        if let status = status, !status.isEmpty {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }

        let urlString = "/owner/products?" + queryItems.map { "\($0.name)=\($0.value!)" }.joined(separator: "&")

        let request = APIRequest(
            path: urlString,
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

    func addProduct(_ newProduct: CreateProductRequest) async throws -> Product {
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

        guard let product = response.data else {
             throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message])
         }
        return product
    }

    func deactivateProduct(id: Int) async throws -> Product {
        let request = APIRequest(
            path: "/owner/\(id)/deactivate",
            method: .POST,
            parameters: nil,
            headers: nil,
            body: nil
        )

        let response = try await client.send(
            request,
            responseType: APIResponse<Product>.self
        )

        guard let updatedProduct = response.data else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message])
        }

        return updatedProduct
    }
}

