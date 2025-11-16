import SwiftUI

@MainActor
final class ManagerHomeViewModel: ObservableObject {
    @Published var factory: Factory?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var employees: [FactoryWorkers] = []

    func fetchFactoryDetails() async {
        isLoading = true
        errorMessage = nil

        do {
            let request = APIRequest(
                path: "/manager/factory/details",
                method: .GET,
                parameters: nil,
                body: nil
            )

            let response = try await APIClient.shared.send(
                request,
                responseType: FactoryResponse.self
            )
            self.factory = response.data
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func fetchMyFactoryEmployees() async {
        isLoading = true
        errorMessage = nil

        do {
            let request = APIRequest(
                path: "/manager/employees/my-factory",
                method: .GET
            )

            let response = try await APIClient.shared.send(
                request,
                responseType: MyFactoryResponse.self
            )
            self.employees = response.data.employees
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
