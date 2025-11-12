import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T?
    let pagination: Pagination?
    let timestamp: String?
}

struct Pagination: Codable {
    let pageNumber: Int?
    let pageSize: Int?
    let totalPages: Int?
    let totalElements: Int?
    let first: Bool?
    let last: Bool?
}

struct FactoryListResponse: Decodable {
    let content: [Factory]
    let totalElements: Int?
    let totalPages: Int?
    let number: Int?
    let size: Int?
    let first: Bool?
    let last: Bool?
    let empty: Bool?
}

struct Factory: Identifiable, Codable, Equatable {
    var id: Int { factoryId }
    let factoryId: Int
    let name: String
    let city: String
    let address: String
    let status: String
    let plantHead: User?
    let plantHeadId: Int?
    let workers: [User]?
    let createdAt: String?
    let updatedAt: String?
}

struct User: Codable, Identifiable, Equatable {
    var id: Int { userId }
    let userId: Int
    let username: String
    let email: String
    let img: String?
    let role: String
    let phone: String
    let password: String?
    let status: String
    let createdAt: String?
    let updatedAt: String?
    let factoryId: Int?
    let factoryName: String?
    let factoryRole: String?
}

struct CreateFactoryRequest: Encodable {
    let name: String
    let city: String
    let address: String
    let plantHeadId: Int
}

struct CreateFactoryResponse: Decodable {
    let factoryId: Int
    let name: String
    let city: String
    let address: String
    let status: String
    let plantHead: User?
    let plantHeadId: Int?
    let workers: [User]?
    let createdAt: String?
    let updatedAt: String?
}

struct FactoryCountResponse: Decodable {
    let count: Int
    let entityType: String
}

struct EmptyResponse: Codable {}

enum SortBy: String, CaseIterable, Identifiable {
    case createdAt
    case name
    case city

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .createdAt: return "Created Date"
        case .name: return "Name"
        case .city: return "City"
        }
    }
}

enum SortDirection: String, CaseIterable, Identifiable {
    case ascending = "ASC"
    case descending = "DESC"

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .ascending: return "Ascending"
        case .descending: return "Descending"
        }
    }
}

struct ToggleResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: T?
    let pagination: Pagination?
    let timestamp: String?
}
