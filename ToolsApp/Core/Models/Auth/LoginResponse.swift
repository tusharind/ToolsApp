import Foundation

struct LoginResponse: Decodable {
    let token: String
    let role: UserRole
}
