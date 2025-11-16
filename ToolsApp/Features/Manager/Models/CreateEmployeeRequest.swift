import SwiftUI

struct CreateEmployeeRequest: Encodable {
    let username: String
    let email: String
    let phone: String
    let role: String
    let bayId: Int
}

struct GenericResponse: Codable {
    let success: Bool
    let message: String
}

