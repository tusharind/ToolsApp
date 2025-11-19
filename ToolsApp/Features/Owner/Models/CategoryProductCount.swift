import SwiftUI

struct CategoryProductCount: Codable {
    let categoryId: Int
    let categoryName: String
    let productCount: Int
}

struct CategoryProductResponse: Codable {
    let content: [CategoryProductCount]
}

struct InventoryRequestBody: Encodable {
    let page: Int
    let size: Int
    let sortBy: String
    let sortDirection: String
}

struct FactoryProductItem: Codable, Identifiable {
    var id: UUID { UUID() }

    let factoryId: Int
    let factoryName: String
    let productId: Int
    let productName: String
    let productCount: Int
}

struct FactoryProductResponse: Codable {
    let content: [FactoryProductItem]
}

struct FactoryInventoryTotal: Identifiable {
    let id = UUID()
    let factoryId: Int
    let factoryName: String
    let totalCount: Int
}
