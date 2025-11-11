import Foundation

@MainActor
final class AdminProfileViewModel: ObservableObject {
    @Published var profile: Adminprofile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isUpdatingImage = false

    private let client = APIClient.shared

    // MARK: - Fetch Profile
    func fetchProfile() async {
        isLoading = true
        errorMessage = nil

        let request = APIRequest(
            path: "/user/1/profile",
            method: .GET,
            parameters: nil,
            headers: nil,
            body: nil
        )

        do {
            let response: AdminProfileResponse = try await client.send(
                request,
                responseType: AdminProfileResponse.self
            )
            if response.success, let data = response.data {
                self.profile = data
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage =
                "Failed to fetch profile: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Update Profile Image
    func updateProfileImage(with newUrl: String) async {
        guard var profile = profile else { return }
        isUpdatingImage = true
        errorMessage = nil

        struct UpdateProfileImageRequest: Encodable {
            let img: String
        }

        let requestBody = UpdateProfileImageRequest(img: newUrl)

        let request = APIRequest(
            path: "/user/1/profile",
            method: .PUT,
            parameters: nil,
            headers: nil,
            body: requestBody
        )

        do {
            let response: AdminProfileResponse = try await client.send(
                request,
                responseType: AdminProfileResponse.self
            )
            if response.success, let updatedProfile = response.data {
                self.profile = updatedProfile
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage =
                "Failed to update image: \(error.localizedDescription)"
        }

        isUpdatingImage = false
    }
}
