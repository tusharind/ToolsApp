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

