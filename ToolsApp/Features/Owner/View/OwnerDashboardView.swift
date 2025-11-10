import Charts
import SwiftUI

struct OwnerDashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    metricsSection
                    chartsSection
                    quickLinksSection
                }
                .padding()
            }
            .navigationTitle("Admin Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.fetchAllMetrics()
            }
        }
    }

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Metrics")
                .font(.title2)
                .bold()

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.bottom, 4)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.metrics) { metric in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(metric.title)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let value = viewModel.value(for: metric) {
                                Text(value)
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(metric.color)
                            } else if viewModel.isLoading {
                                ProgressView()
                                    .tint(metric.color)
                            } else {
                                Text("\(viewModel.productCount ?? 0)")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(width: 180, height: 100, alignment: .leading)
                        .background(metric.color.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Analytics")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
                Text("Sales by Factory (Month-wise)")
                    .font(.headline)

                Chart {
                    BarMark(
                        x: .value("Month", "Jan"),
                        y: .value("Sales", 12000)
                    )
                    BarMark(
                        x: .value("Month", "Feb"),
                        y: .value("Sales", 16000)
                    )
                    BarMark(
                        x: .value("Month", "Mar"),
                        y: .value("Sales", 19000)
                    )
                }
                .frame(height: 220)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Product Growth Trend")
                    .font(.headline)

                Chart {
                    LineMark(x: .value("Month", "Jan"), y: .value("Growth", 20))
                    LineMark(x: .value("Month", "Feb"), y: .value("Growth", 35))
                    LineMark(x: .value("Month", "Mar"), y: .value("Growth", 60))
                    LineMark(x: .value("Month", "Apr"), y: .value("Growth", 20))
                }
                .frame(height: 220)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }

    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Links")
                .font(.title2)
                .bold()

            VStack{
                HStack {
                    QuickLinkCard(
                        title: "Factory Products",
                        systemImage: "shippingbox.fill",
                        destination: ProductsListView()
                    )
                    
                    QuickLinkCard(
                        title: "Factory List",
                        systemImage: "building.2.fill",
                        destination: FactoriesListView()
                    )
                }
                HStack {
                    
                    QuickLinkCard(
                        title: "My Profile",
                        systemImage: "person",
                        destination: AdminProfileView()
                    )
                    
                    QuickLinkCard(
                        title: "Central Office",
                        systemImage: "globe.central.south.asia.fill",
                        destination: OfficesListView()
                    )
                }
            }
        }
    }
}

struct QuickLinkCard<Destination: View>: View {
    let title: String
    let systemImage: String
    let destination: Destination
    @State private var isPressed = false

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 32))
                    .foregroundColor(.blue)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(CardButtonStyle(isPressed: $isPressed))
    }
}

struct CardButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = newValue
                }
            }
    }
}

#Preview {
    OwnerDashboardView()
}
