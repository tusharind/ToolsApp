import SwiftUI

struct EmployeeListView: View {
    @StateObject private var viewModel = EmployeeListViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    VStack(alignment: .leading, spacing: 8) {
                        TextField(
                            "Search factories",
                            text: $viewModel.factorySearchText
                        )
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                FactoryButton(
                                    title: "All",
                                    isSelected: viewModel.selectedFactoryId
                                        == nil
                                ) {
                                    viewModel.selectedFactoryId = nil
                                    Task { await viewModel.fetchEmployees() }
                                }

                                ForEach(
                                    viewModel.filteredFactories,
                                    id: \.factoryId
                                ) { factory in
                                    FactoryButton(
                                        title: factory.name,
                                        isSelected: viewModel.selectedFactoryId
                                            == factory.factoryId
                                    ) {
                                        viewModel.selectedFactoryId =
                                            factory.factoryId
                                        Task {
                                            await viewModel.fetchEmployees()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
                    .padding(.horizontal)

                    Picker("Role", selection: $viewModel.selectedRole) {
                        ForEach(EmployeeListViewModel.Role.allCases, id: \.self)
                        { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: viewModel.selectedRole) {
                        newValue,
                        oldValue in
                        Task { await viewModel.fetchEmployees() }
                    }

                    TextField("Search employees", text: $viewModel.searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onChange(of: viewModel.searchText) {
                            newValue,
                            oldValue in
                            Task { await viewModel.fetchEmployees() }
                        }

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading employees...")
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    } else if viewModel.employees.isEmpty {
                        Spacer()
                        Text("No employees found")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.employees) { employee in
                                EmployeeRow(employee: employee)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .shadow(
                                        color: Color.black.opacity(0.03),
                                        radius: 3,
                                        x: 0,
                                        y: 2
                                    )
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Employees")
        }
    }
}

struct FactoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(10)
        }
    }
}

struct EmployeeRow: View {
    let employee: Employee

    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            if let imgPath = employee.img, !imgPath.isEmpty {
                AsyncImage(url: URL(string: imgPath)) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 50)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(employee.username)
                    .font(.headline)
                Text(employee.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Role: \(employee.role), Status: \(employee.status)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        }
        .padding()
    }
}
