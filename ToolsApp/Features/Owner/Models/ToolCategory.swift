import Foundation

struct ToolCategory: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
}

struct ToolCategoryResponse: Codable {
    let success: Bool
    let message: String
    let data: ToolCategoryData
}

struct ToolCategoryData: Codable {
    let content: [ToolCategory]
    let pageable: Pageable
    let last: Bool
    let totalPages: Int
    let totalElements: Int
    let size: Int
    let number: Int
    let numberOfElements: Int
    let first: Bool
    let empty: Bool
}

struct CreateToolCategoryRequest: Codable {
    let name: String
    let description: String
}

struct CreateToolCategoryResponse: Codable {
    let success: Bool
    let message: String
    let data: ToolCategory
}

struct ToolCreationResponse: Codable {
    let success: Bool
    let message: String
    let data: ToolItem?
    let pagination: Pagination?
    let timestamp:String 
}

