import SwiftUI

struct ManageEmployeesView: View {
    @StateObject private var viewModel = ManagerHomeViewModel()
    @State private var selectedRole = "ALL"
    @State private var showCreateEmployee = false

    private let roles = ["ALL", "CHIEF_SUPERVISOR", "WORKER"]

    var filteredEmployees: [FactoryWorkers] {
        selectedRole == "ALL"
            ? viewModel.employees
            : viewModel.employees.filter { $0.role == selectedRole }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Picker("Role", selection: $selectedRole) {
                    ForEach(roles, id: \.self) { role in
                        Text(role.capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if viewModel.isLoading {
                    ProgressView("Loading employees...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredEmployees.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "person.2.slash")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No employees found.")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredEmployees) { worker in
                        WorkerRow(worker: worker)
                    }
                    .listStyle(.insetGrouped)
                }

                Button {
                    showCreateEmployee = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Add Employee", systemImage: "plus.circle.fill")
                            .font(.headline)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)
                .sheet(isPresented: $showCreateEmployee) {

                    CreateEmployeeView {
                        Task {
                            await viewModel.fetchMyFactoryEmployees()
                        }
                    }
                }
            }
            .navigationTitle("Manage Employees")
            .task {
                await viewModel.fetchFactoryDetails()
                await viewModel.fetchMyFactoryEmployees()
            }
        }
    }
}
