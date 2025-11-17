import Foundation

struct FactoryWorkers: Identifiable, Codable, Hashable {
    let id: Int
    let username: String
    let email: String
    let img: String?
    let phone: String
    let role: String
    let status: String
    let createdAt: String
    let factories: [EmployeeFactory]

    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case username, email, img, phone, role, status, createdAt, factories
    }
}

struct EmployeeFactory: Codable, Hashable {
    let factoryId: Int
    let factoryName: String
    let location: String
}

struct ManagerPendingRequestData: Decodable {
    let content: [ManagerPendingRequest]
    let pageable: Pageable?
    let totalElements: Int?
    let totalPages: Int?
    let last: Bool?
    let size: Int?
    let number: Int?
    let sort: Sort?
    let numberOfElements: Int?
    let first: Bool?
    let empty: Bool?
}

struct ManagerPendingRequest: Identifiable, Decodable {
    let id: Int
    let factoryId: Int
    let factoryName: String
    let productId: Int
    let productName: String
    let qtyRequested: Int
    let status: String
    let createdAt: String
    let requestedByUserId: Int?
    let requestedByUserName: String?
    let completedAt: String?
    let currentFactoryStock: Int
}

