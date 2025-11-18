import SwiftUI

struct ManagerHomeView: View {
    @StateObject private var viewModel = ManagerHomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    if let factory = viewModel.factory {
                        VStack(alignment: .leading, spacing: 10) {

                            Text(factory.name)
                                .font(.title3.bold())

                            HStack(spacing: 6) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.blue)
                                Text("\(factory.city), \(factory.address)")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                            HStack(spacing: 6) {
                                Text("Status:")
                                    .foregroundColor(.secondary)

                                Text(factory.status)
                                    .bold()
                                    .foregroundColor(
                                        factory.status == "ACTIVE"
                                            ? .green
                                            : .red
                                    )
                            }
                            .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        )
                    } else {
                        VStack {
                            Text("No factory details available.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 50)
                    }

                    if let head = viewModel.factory?.plantHead {
                        VStack(alignment: .leading, spacing: 6) {

                            Text("Plant Head / Manager")
                                .font(.headline)

                            Text(head.username)
                                .font(.body.bold())

                            Text(head.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(head.phone)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("Role: \(head.role)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.08))
                                .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Links")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack {
                            QuickLinkCard(
                                title: "Manage Employees",
                                systemImage: "person.3.fill",
                                destination: ManageEmployeesView()
                            )
                            QuickLinkCard(
                                title: "Pending Requests",
                                systemImage: "shippingbox.fill",
                                destination: PendingRestockRequestsView()
                            )
                            QuickLinkCard(
                                title: "Stock Up",
                                systemImage: "arrow.up.bin",
                                destination: StockProductionView()
                            )
                            QuickLinkCard(
                                title: "My Factory Tools",
                                systemImage: "hammer.fill",
                                destination: ManagerFactoryToolsView()
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 10)

                }
                .padding()
            }
            .navigationTitle("Manager Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetchFactoryDetails()
                await viewModel.fetchMyFactoryEmployees()
            }
        }
    }
}

