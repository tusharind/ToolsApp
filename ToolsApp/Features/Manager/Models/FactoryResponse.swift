import SwiftUI

struct FactoryResponse: Decodable {
    let success: Bool
    let message: String
    let data: Factory
}

struct PlantHead: Decodable {
    let userId: Int
    let username: String
    let email: String
    let phone: String
    let role: String
}
