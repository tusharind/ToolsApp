import Foundation
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var factoryCount: Int?
    @Published var productCount: Int?
    @Published var managerCount: Int?
    @Published var workerCount: Int?
    
    @Published var errorMessage: String?
    @Published var isLoading = false

    @Published var metrics: [DashboardMetric] = [
        DashboardMetric(title: "Factories", color: .blue),
        DashboardMetric(title: "Products", color: .green),
        DashboardMetric(title: "Workers", color: .orange),
    ]

    private let client = APIClient.shared

    func fetchAllMetrics() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        async let factoryTask = fetchFactoryCount()
        async let productTask = fetchProductCount()
    

        _ = await (factoryTask, productTask)

        isLoading = false
    }

    func fetchFactoryCount() async {
        let request = APIRequest(path: "/owner/count", method: .GET, parameters: nil, headers: nil, body: nil)
        do {
            let response = try await client.send(request, responseType: APIResponse<FactoryCountResponse>.self)
            if response.success, let data = response.data {
                self.factoryCount = data.count
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = "Error fetching factory count: \(error.localizedDescription)"
        }
    }

    func fetchProductCount() async {
        let request = APIRequest(path: "/owner/productCount", method: .GET, parameters: nil, headers: nil, body: nil)
        do {
            let response = try await client.send(request, responseType: APIResponse<ProductCountResponse>.self)
            if response.success, let data = response.data {
                self.productCount = data.count
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = "Error fetching product count: \(error.localizedDescription)"
        }
    }

    func value(for metric: DashboardMetric) -> String? {
        switch metric.title {
        case "Factories": return factoryCount.map(String.init)
        case "Products": return productCount.map(String.init)
        case "Managers": return managerCount.map(String.init)
        case "Workers": return workerCount.map(String.init)
        default: return nil
        }
    }
}

