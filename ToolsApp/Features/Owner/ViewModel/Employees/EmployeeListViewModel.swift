import SwiftUI

@MainActor
final class EmployeeListViewModel: ObservableObject {

    @Published var employees: [Employee] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedRole: Role = .worker
    @Published var selectedFactoryId: Int? = nil

    @Published var factories: [Factory] = []
    @Published var factorySearchText: String = ""

    enum Role: String, CaseIterable {
        case worker = "WORKER"
        case chiefSupervisor = "CHIEF_SUPERVISOR"

        var displayName: String {
            switch self {
            case .worker: return "Workers"
            case .chiefSupervisor: return "Chief Supervisors"
            }
        }
    }

    init() {
        Task {
            await fetchFactories()
            await fetchEmployees()
        }
    }

    func fetchEmployees() async {
        isLoading = true
        errorMessage = nil

        var path =
            "/manager/employees?search=\(searchText)&role=\(selectedRole.rawValue)"
        if let factoryId = selectedFactoryId {
            path += "&factoryId=\(factoryId)"
        }

        let request = APIRequest(path: path, method: .GET)

        do {
            let response: EmployeeResponse = try await APIClient.shared.send(
                request,
                responseType: EmployeeResponse.self
            )
            employees = response.data.employees
        } catch {
            errorMessage =
                "Failed to load employees: \(error.localizedDescription)"
            employees = []
        }

        isLoading = false
    }

    func fetchFactories() async {
        let request = APIRequest(
            path: "/owner/factories?size=100",
            method: .GET
        )

        do {
            let response = try await APIClient.shared.send(
                request,
                responseType: APIResponse<FactoryListResponse>.self
            )
            if response.success, let data = response.data {
                factories = data.content
            }
        } catch {
            print("Failed to fetch factories: \(error.localizedDescription)")
        }
    }

    var filteredFactories: [Factory] {
        if factorySearchText.isEmpty { return factories }
        return factories.filter {
            $0.name.lowercased().contains(factorySearchText.lowercased())
        }
    }
}
