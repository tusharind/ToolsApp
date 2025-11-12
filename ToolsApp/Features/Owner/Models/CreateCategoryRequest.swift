import Foundation

struct CreateCategoryRequest: Codable {
    let categoryName: String
    let description: String
}

struct CategoriesResponseData: Codable {
    let content: [CategoryName]
    let pageable: Pageable
    let last: Bool
    let totalElements: Int
    let totalPages: Int
    let size: Int
    let number: Int
    let sort: SortInfo
    let numberOfElements: Int
    let first: Bool
    let empty: Bool
}

struct CategoryName: Identifiable, Codable, Equatable{
    let id: Int
    let categoryName: String
    let description: String
    let productCount: Int
}

