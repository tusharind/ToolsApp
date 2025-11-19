import SwiftUI

struct AvailableManagersView: View {
    @StateObject private var viewModel = ManagersViewModel()

    @State private var showingAddManager = false
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var searchTask: Task<Void, Never>? = nil
    @State private var showDeleteConfirm = false
    @State private var managerToDelete: Manager? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    TextField("Search managers...", text: $viewModel.searchText)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onChange(of: viewModel.searchText) { newValue, _ in
                            searchTask?.cancel()
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 900_000_000)
                                if !Task.isCancelled {
                                    await viewModel.fetchAvailableManagers()
                                }
                            }
                        }

                    VStack {
                        if viewModel.isLoading {
                            Spacer()
                            ProgressView("Loading managers...")
                            Spacer()
                        } else if let error = viewModel.errorMessage {
                            Spacer()
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                            Button("Retry") {
                                Task { await viewModel.fetchAvailableManagers() }
                            }
                            .buttonStyle(.borderedProminent)
                            Spacer()
                        } else if viewModel.availableManagers.isEmpty {
                            Spacer()
                            Text("No managers found")
                                .foregroundColor(.gray)
                            Spacer()
                        } else {
                            List {
                                ForEach(viewModel.availableManagers) { manager in
                                    ManagerCardView(
                                        manager: manager,
                                        onDelete: {
                                            managerToDelete = manager
                                            showDeleteConfirm = true
                                        }
                                    )
                                    .listRowSeparator(.hidden)
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                }

                addButton
            }
            .navigationTitle("Available Managers")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete Manager?",
                   isPresented: $showDeleteConfirm,
                   actions: {
                Button("Cancel", role: .cancel) {}

                Button("Delete", role: .destructive) {
                    Task {
                        if let manager = managerToDelete {
                            await viewModel.deleteManager(id: manager.id)
                            await viewModel.fetchAvailableManagers()
                        }
                        managerToDelete = nil
                    }
                }
            }, message: {
                Text("Are you sure you want to delete this manager?")
            })
            .onAppear {
                Task { await viewModel.fetchAvailableManagers() }
            }
            .sheet(isPresented: $showingAddManager) {
                addManagerSheet
            }
        }
    }

    private var addButton: some View {
        Button {
            showingAddManager = true
        } label: {
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
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section {
                    Button {
                        Task {
                            await viewModel.createManager(
                                username: username,
                                email: email,
                                phone: phone
                            )
                            if viewModel.errorMessage == nil {
                                showingAddManager = false
                                username = ""
                                email = ""
                                phone = ""
                                await viewModel.fetchAvailableManagers()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Create Manager").frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(username.isEmpty || email.isEmpty || phone.isEmpty)
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

