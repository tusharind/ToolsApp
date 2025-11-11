import Foundation
import SwiftUI

struct Product: Identifiable, Codable {
    let id: Int
    let name: String
    let image: String
    let prodDescription: String
    let price: Double
    let rewardPts: Int
    let status: String
    let categoryId: Int
    let categoryName: String
    let createdAt: String
    let updatedAt: String
}

struct CreateProductRequest: Encodable {
    let name: String
    let image: String
    let prodDescription: String
    let price: Double
    let rewardPts: Int
    let categoryId: Int
}

struct PaginatedProductsResponse: Decodable {
    let success: Bool
    let message: String
    let data: ProductPageData
    let pagination: Pagination?
    let timestamp: String
}

struct ProductPageData: Decodable {
    let content: [Product]
    let pageable: Pageable?
    let totalPages: Int
    let totalElements: Int
    let number: Int
    let size: Int
    let first: Bool
    let last: Bool
    let empty: Bool
}

struct Pageable: Decodable {
    let pageNumber: Int
    let pageSize: Int
}

struct DashboardMetric: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
}

struct ProductCountResponse: Decodable {
    let count: Int
    let entityType: String
}
