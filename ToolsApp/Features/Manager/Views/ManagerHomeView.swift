import SwiftUI

struct ManagerHomeView: View {
    @StateObject private var viewModel = ManagerHomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    if let factory = viewModel.factory {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(factory.name)
                                .font(.title2.bold())

                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                Text("\(factory.city), \(factory.address)")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                            HStack {
                                Text("Status:")
                                Text(factory.status)
                                    .bold()
                                    .foregroundColor(
                                        factory.status == "ACTIVE"
                                            ? .green : .red
                                    )
                            }
                            .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                    } else {
                        VStack {
                            Text("No factory details available.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 50)
                    }

                    if let head = viewModel.factory?.plantHead {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Plant Head / Manager")
                                .font(.headline)
                            Text("\(head.username)")
                            Text("\(head.email)")
                            Text("\(head.phone)")
                            Text("Role: \(head.role)")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Links")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
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

                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 120)
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
