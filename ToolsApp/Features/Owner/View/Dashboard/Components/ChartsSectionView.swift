import Charts
import SwiftUI

struct ChartsSectionView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Analytics")
                .font(.title2)
                .bold()

            categoryChart

            if !viewModel.factoryInventoryTotals.isEmpty {
                stockChart
            }
        }
    }

    private var categoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Products per Category")
                .font(.headline)

            Chart(viewModel.categoryProductCounts, id: \.categoryId) { item in
                SectorMark(
                    angle: .value("Count", item.productCount),
                    innerRadius: .ratio(0.4),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Category", item.categoryName))
            }
            .frame(height: 260)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private var stockChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stock Distribution by Factory")
                .font(.headline)

            Chart(viewModel.factoryInventoryTotals, id: \.factoryId) { item in
                SectorMark(
                    angle: .value("Stock", item.totalCount),
                    innerRadius: .ratio(0.4),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Factory", item.factoryName))
            }
            .frame(height: 260)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
