import SwiftUI

@MainActor
final class CreateRestockRequestViewModel: ObservableObject {

    @Published var selectedFactoryId: Int?
    @Published var selectedProductId: Int?
    @Published var qtyRequested: String = ""

    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var createdRequest: RestockRequest?

    @Published var myRequests: [RestockRequest] = []
    @Published var isLoadingMyRequests = false
    @Published var myRequestsError: String?

    var isValid: Bool {
        guard let factoryId = selectedFactoryId,
            let productId = selectedProductId,
            let qty = Int(qtyRequested),
            qty > 0
        else { return false }
        return true
    }

    func createRestockRequest() async {
        guard isValid else {
            errorMessage = "Please fill all fields correctly."
            return
        }

        isSubmitting = true
        errorMessage = nil
        successMessage = nil

        let body = CreateRestockRequestBody(
            factoryId: selectedFactoryId!,
            productId: selectedProductId!,
            qtyRequested: Int(qtyRequested) ?? 0
        )

        let request = APIRequest(
            path: "/inventory/central-office/restock-requests",
            method: .POST,
            headers: [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "ngrok-skip-browser-warning": "true",
            ],
            body: body
        )

        do {
            let response = try await APIClient.shared.send(
                request,
                responseType: RestockRequestResponse.self
            )

            if response.success, let data = response.data {
                createdRequest = data
                successMessage = "Restock request created successfully."
            } else {
                errorMessage = response.message ?? "Something went wrong."
            }

        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    func fetchMyRestockRequests(
        page: Int = 0,
        size: Int = 20,
        sortBy: String = "createdAt",
        direction: String = "DESC"
    ) async {

        isLoadingMyRequests = true
        myRequestsError = nil

        let path =
            "/inventory/central-office/my-restock-requests?page=\(page)&size=\(size)&sortBy=\(sortBy)&sortDirection=\(direction)"

        let request = APIRequest(
            path: path,
            method: .GET,
            headers: ["ngrok-skip-browser-warning": "true"]
        )

        do {

            let response = try await APIClient.shared.send(
                request,
                responseType: RestockRequestListResponse.self
            )

            if response.success, let pageData = response.data {
                self.myRequests = pageData.content
            } else {
                self.myRequestsError =
                    response.message ?? "Failed to load requests."
            }

        } catch {
            self.myRequestsError = error.localizedDescription
        }

        isLoadingMyRequests = false
    }
}
