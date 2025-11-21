import SwiftUI

struct ManagersView: View {
    @StateObject private var viewModel = ManagersViewModel()

    @State private var showingAddManager = false
    @State private var managerToDelete: Manager? = nil
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 12) {
                    searchField
                    contentView
                        .task { await viewModel.fetchManagers() }
                }

                addButton
            }
            .navigationTitle("Managers")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                "Delete Manager?",
                isPresented: $showDeleteConfirm,
                actions: {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        Task {
                            if let manager = managerToDelete {
                                await viewModel.deleteManager(manager)
                                await viewModel.fetchManagers()
                            }
                            managerToDelete = nil
                        }
                    }
                },
                message: {
                    Text("Are you sure you want to delete this manager?")
                }
            )
        }
        .sheet(isPresented: $showingAddManager) {
            addManagerSheet
        }
    }

    private var searchField: some View {
        TextField("Search managers...", text: $viewModel.searchText)
            .padding(10)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView("Loading managers...")
            Spacer()
        } else if let error = viewModel.errorMessage {
            errorView(error)
        } else if viewModel.managers.isEmpty {
            Spacer()
            Text("No managers found")
                .foregroundColor(.gray)
            Spacer()
        } else {
            List(viewModel.factoryManagers) { manager in
                ManagerCardView(
                    manager: manager,
                    onDelete: {
                        managerToDelete = manager
                        showDeleteConfirm = true
                    }
                )
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            Button("Retry") {
                Task { await viewModel.fetchManagers() }
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }

    private var addButton: some View {
        Button(action: { showingAddManager = true }) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .padding()
    }

    private var addManagerSheet: some View {
        NavigationStack {
            Form {
                Section("New Manager Details") {
                    ValidatedTextField(
                        title: "Username",
                        text: $viewModel.newUsername,
                        touched: .constant(true),
                        errorMessage: viewModel.usernameError
                            ?? "Username cannot be empty"
                    )
                    ValidatedTextField(
                        title: "Email",
                        text: $viewModel.newEmail,
                        touched: .constant(true),
                        keyboard: .emailAddress,
                        errorMessage: viewModel.emailError
                            ?? "Enter a valid email"
                    )
                    ValidatedTextField(
                        title: "Phone",
                        text: $viewModel.newPhone,
                        touched: .constant(true),
                        keyboard: .phonePad,
                        errorMessage: viewModel.phoneError
                            ?? "Enter a valid phone number"
                    )
                }

                Section {
                    Button {
                        Task { await viewModel.createManager() }
                        if viewModel.errorMessage == nil {
                            showingAddManager = false
                            Task { await viewModel.fetchManagers() }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Create Manager").frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }
            .navigationTitle("Add Manager")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { showingAddManager = false }
                }
            }
        }
    }
}
