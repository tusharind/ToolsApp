import SwiftUI

@MainActor
final class RestockRequestsViewModel: ObservableObject {
    @Published var restockRequests: [ManagerPendingRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var selectedStatus: String = "PENDING"
    @Published var sortDirection: String = "DESC"
    @Published var page: Int = 0
    @Published var pageSize: Int = 20

    func fetchRestockRequests() async {
        isLoading = true
        errorMessage = nil

        do {
            let urlPath =
                "/inventory/factories/my-restock-requests?status=\(selectedStatus)&sortBy=createdAt&sortDirection=\(sortDirection)&page=\(page)&size=\(pageSize)"

            let request = APIRequest(
                path: urlPath,
                method: .GET,
                body: nil
            )

            let response = try await APIClient.shared.send(
                request,
                responseType: ManagerPendingRequestListResponse.self
            )

            self.restockRequests = response.data?.content ?? []
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func completeRequest(
        _ request: ManagerPendingRequest,
        completion: @escaping (Bool, String?) -> Void
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let urlPath =
                "/inventory/factories/restock-requests/\(request.id)/complete"
            let apiRequest = APIRequest(path: urlPath, method: .PUT, body: nil)

            let response = try await APIClient.shared.send(
                apiRequest,
                responseType: ManagerPendingRequestSingleResponse.self
            )

            if response.success, let updatedRequest = response.data {
                if let index = restockRequests.firstIndex(where: {
                    $0.id == request.id
                }) {
                    restockRequests[index] = updatedRequest
                }
                completion(true, nil)
            } else {

                completion(false, response.message)
            }

        } catch {
            completion(false, error.localizedDescription)
        }

        isLoading = false
    }

    func toggleSortDirection() async {
        sortDirection = (sortDirection == "ASC") ? "DESC" : "ASC"
        await fetchRestockRequests()
    }

    func setStatus(_ status: String) async {
        selectedStatus = status.uppercased()
        await fetchRestockRequests()
    }
}

