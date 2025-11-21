import Charts
import SwiftUI

@MainActor
struct OwnerDashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var navigateToProfile = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {

                MetricsSectionView(viewModel: viewModel)
                ChartsSectionView(viewModel: viewModel)

            }
            .padding()
        }
        .navigationTitle("Admin Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    navigateToProfile = true
                } label: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            AdminProfileView()
        }
        .task {
            await viewModel.fetchAllMetrics()
        }
    }
}


