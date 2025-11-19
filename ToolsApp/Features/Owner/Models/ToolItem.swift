import SwiftUI

struct ToolItem: Identifiable, Codable {
    let id: Int
    let name: String
    let categoryName: String
    let categoryId: Int
    let type: String
    let isExpensive: String
    let threshold: Int
    let imageUrl: String
    let status: String
    let createdAt: String
}

struct PaginatedResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: PaginatedToolsData<T>
}

struct PaginatedToolsData<T: Codable>: Codable {
    let content: [T]
    let last: Bool
    let totalPages: Int
    let totalElements: Int
    let numberOfElements: Int
    let size: Int
    let number: Int
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let text: String
}

struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct Tools: Identifiable, Decodable, Equatable {
    let id: Int
    let toolId: Int
    let toolName: String
    let toolCategory: String
    let toolType: String
    let isExpensive: String
    let imageUrl: String
    let totalQuantity: Int
    let availableQuantity: Int
    let issuedQuantity: Int
    let lastUpdatedAt: String
}

struct FactoryToolsResponse: Decodable {
    let success: Bool
    let message: String
    let data: FactoryToolsData
}

struct FactoryToolsData: Decodable {
    let content: [Tools]
    let pageable: Pageable
    let last: Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
    let number: Int
    let sort: Sort
    let numberOfElements: Int
    let first: Bool
    let empty: Bool
}

struct CategoryProductCountResponse: Codable {
    let success: Bool
    let message: String
    let data: CategoryProductData?
    let pagination: Pagination?
    let timestamp: String?
}

struct CategoryProductData: Codable {
    let content: [CategoryProductsCount]
    let pageable: Pageable?
    let last: Bool
    let totalPages: Int
    let totalElements: Int
    let numberOfElements: Int
    let size: Int
    let number: Int
    let sort: Sort?
    let first: Bool
    let empty: Bool
}

struct CategoryProductsCount: Identifiable, Codable {
    let categoryId: Int
    let categoryName: String
    let productCount: Int
    
    var id: Int { categoryId }
}



