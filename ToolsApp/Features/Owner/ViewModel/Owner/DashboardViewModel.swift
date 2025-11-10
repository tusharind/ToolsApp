import Foundation
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var factoryCount: Int?
    @Published var managerCount: Int?
    @Published var workerCount: Int?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var productCount: Int?

    @Published var metrics: [DashboardMetric] = [
        DashboardMetric(title: "Factories", color: .blue),
        DashboardMetric(title: "Managers", color: .green),
        DashboardMetric(title: "Workers", color: .orange),
    ]

    private let client = APIClient.shared

    func fetchAllMetrics() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        async let factoryTask = fetchFactoryCount()
        async let productTask = fetchProductCount()

        await factoryTask
        await productTask

        isLoading = false
    }

    func fetchFactoryCount() async {
        print("Fetching factory count...")

        let request = APIRequest(
            path: "/owner/count",
            method: .GET,
            parameters: nil,
            headers: nil,
            body: nil
        )

        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<FactoryCountResponse>.self
            )
            print("Response received: \(response)")

            if let data = response.data {
                factoryCount = data.count
                print("Factory count updated: \(data.count)")
            } else {
                errorMessage = "No factory count data found."
            }
        } catch {
            errorMessage =
                "Error fetching factory count: \(error.localizedDescription)"
            print("Error fetching factory count: \(error.localizedDescription)")
        }
    }
    
    
    func fetchProductCount() async {
        print("Fetching factory count...")

        let request = APIRequest(
            path: "/owner/productCount",
            method: .GET,
            parameters: nil,
            headers: nil,
            body: nil
        )

        do {
            let response = try await client.send(
                request,
                responseType: APIResponse<ProductCountResponse>.self
            )
            print("Response received: \(response)")

            if let data = response.data {
                productCount = data.count
                print("Factory count updated: \(data.count)")
            } else {
                errorMessage = "No factory count data found."
            }
        } catch {
            errorMessage =
                "Error fetching factory count: \(error.localizedDescription)"
            print("Error fetching factory count: \(error.localizedDescription)")
        }
    }


    func value(for metric: DashboardMetric) -> String? {
        switch metric.title {
        case "Factories":
            return factoryCount.map(String.init)
        case "Managers":
            return managerCount.map(String.init)
        case "Workers":
            return workerCount.map(String.init)
        default:
            return nil
        }
    }
}

