import Foundation

struct Manager: Identifiable, Codable, Equatable {
    let id: Int
    let username: String
    let email: String
    let img: String?
    let profileImage: String?
    let role: String
    let phone: String
    let password: String?
    let status: String
    let createdAt: String
    let updatedAt: String
    let factoryId: Int?
    let factoryName: String?
    let factoryRole: String?

    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case username, email, img, profileImage, role, phone, password, status,
            createdAt, updatedAt, factoryId, factoryName, factoryRole
    }
}

struct ManagerListResponse: Codable {
    let content: [Manager]
}

struct ManagerSearchResponse: Codable {
    let success: Bool
    let message: String
    let data: ManagerSearchData
    let pagination: String?
    let timestamp: String?
}

struct ManagerSearchData: Codable {
    let content: [Manager]
    let pageable: Pageable
    let totalElements: Int
    let totalPages: Int
    let last: Bool
    let first: Bool
    let size: Int
    let number: Int
    let sort: SortInfo
    let numberOfElements: Int
    let empty: Bool
}

struct SortInfo: Codable {
    let unsorted: Bool
    let empty: Bool
    let sorted: Bool
}
