import SwiftUI

struct ManagerHomeView: View {
    @StateObject private var viewModel = ManagerHomeViewModel()
    @State private var showManageEmployees = false

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

                    Button {
                        showManageEmployees = true
                    } label: {
                        Label("Manage Employees", systemImage: "person.3.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)
                    .navigationDestination(isPresented: $showManageEmployees) {
                        ManageEmployeesView()
                    }
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
