import Foundation

final class AuthRepository {
    private let network = APIClient.shared

    func login(email: String, password: String) async throws -> LoginResponse {
        let body = [
            "email": email,
            "password": password,
        ]

        let request = APIRequest(
            path: APIEndpoints.login,
            method: .POST,
            parameters: nil,
            headers: nil,
            body: body,
        )

        let response: LoginResponse = try await network.send(
            request,
            responseType: LoginResponse.self
        )
        return response
    }
}
