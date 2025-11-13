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


