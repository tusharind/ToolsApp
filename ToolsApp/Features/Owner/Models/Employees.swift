import Foundation

struct EmployeeResponse: Codable {
    let success: Bool
    let message: String
    let data: EmployeeData
    let pagination: Pagination?
    let timestamp: String?
}

struct EmployeeData: Codable {
    let employees: [Employee]
    let totalCount: Int
    let factoryId: Int?
    let factoryName: String?
}

struct Employee: Identifiable, Codable {
    let id: Int
    let username: String
    let email: String
    let img: String?
    let phone: String
    let role: String
    let status: String
    let createdAt: String
    let factories: [FactoryEmployee]
    
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case username, email, img, phone, role, status, createdAt, factories
    }
}

struct FactoryEmployee: Codable {
    let factoryId: Int
    let factoryName: String
    let location: String
}


