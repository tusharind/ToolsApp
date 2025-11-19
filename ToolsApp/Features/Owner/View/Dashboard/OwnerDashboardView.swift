//import Charts
//import SwiftUI
//
//struct OwnerDashboardView: View {
//    @StateObject private var viewModel = DashboardViewModel()
//    @State private var navigateToProfile = false
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 32) {
//                    metricsSection
//                    chartsSection(vm: viewModel)
//                    quickLinksSection
//                }
//                .padding()
//            }
//            .navigationTitle("Admin Dashboard")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        navigateToProfile = true
//                    } label: {
//                        Image(systemName: "person.circle.fill")
//                            .font(.system(size: 28))
//                            .foregroundColor(.blue)
//                    }
//                }
//            }
//            .background(
//                NavigationLink(
//                    destination: AdminProfileView(),
//                    isActive: $navigateToProfile
//                ) {
//                    EmptyView()
//                }
//                .hidden()
//            )
//            .task {
//                await viewModel.fetchAllMetrics()
//            }
//        }
//    }
//
//    private func chartsSection(vm: DashboardViewModel) -> some View {
//        VStack(alignment: .leading, spacing: 24) {
//            Text("Analytics")
//                .font(.title2)
//                .bold()
//
//            VStack(alignment: .leading, spacing: 12) {
//                Text("Products per Category")
//                    .font(.headline)
//
//                Chart(vm.categoryProductCounts, id: \.categoryId) { item in
//                    SectorMark(
//                        angle: .value("Count", item.productCount),
//                        innerRadius: .ratio(0.4),
//                        angularInset: 2
//                    )
//                    .foregroundStyle(by: .value("Category", item.categoryName))
//                }
//                .frame(height: 260)
//                .padding()
//                .background(Color(.systemGray6))
//                .cornerRadius(12)
//            }
//
//            if !vm.factoryInventoryTotals.isEmpty {
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Stock Distribution by Factory")
//                        .font(.headline)
//
//                    Chart(vm.factoryInventoryTotals, id: \.factoryId) { item in
//                        SectorMark(
//                            angle: .value("Stock", item.totalCount),
//                            innerRadius: .ratio(0.4),
//                            angularInset: 2
//                        )
//                        .foregroundStyle(
//                            by: .value("Factory", item.factoryName)
//                        )
//                    }
//                    .frame(height: 260)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(12)
//                }
//            }
//        }
//    }
//
//    private var metricsSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Key Metrics")
//                .font(.title2)
//                .bold()
//
//            if let error = viewModel.errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
//                    .padding(.bottom, 4)
//            }
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 16) {
//                    ForEach(viewModel.metrics) { metric in
//                        VStack(alignment: .leading, spacing: 6) {
//                            Text(metric.title)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//
//                            if let value = viewModel.value(for: metric) {
//                                Text(value)
//                                    .font(.title)
//                                    .bold()
//                                    .foregroundColor(metric.color)
//                            } else if viewModel.isLoading {
//                                ProgressView()
//                                    .tint(metric.color)
//                            } else {
//                                Text("\(viewModel.productCount ?? 0)")
//                                    .font(.title)
//                                    .bold()
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        .padding()
//                        .frame(width: 180, height: 100, alignment: .leading)
//                        .background(metric.color.opacity(0.1))
//                        .cornerRadius(12)
//                    }
//                }
//                .padding(.horizontal, 4)
//            }
//        }
//    }
//}
//
//#Preview {
//    OwnerDashboardView()
//}
