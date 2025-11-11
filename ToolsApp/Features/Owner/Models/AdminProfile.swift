import Foundation

struct Adminprofile: Identifiable, Codable {
    let id: Int
    let username: String
    let email: String
    let img: String?
    let phone: String?
    let role: String?
    let status: String?

    private enum CodingKeys: String, CodingKey {
        case id = "userId"
        case username
        case email
        case img
        case phone
        case role
        case status
    }
}

struct AdminProfileResponse: Codable {
    let success: Bool
    let message: String
    let data: Adminprofile?
    let pagination: Pagination?
    let timestamp: String
}

struct UpdateProfileImageRequest: Encodable {
    let img: String
}
