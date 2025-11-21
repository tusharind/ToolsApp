import SwiftUI

struct AvailableManagersView: View {
    @StateObject private var viewModel = ManagersViewModel()
    @State private var showAddSheet = false
    @State private var showDeleteConfirm = false
    @State private var selectedManager: Manager?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    TextField("Search managers...", text: $viewModel.searchText)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding()

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading managers...")
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        VStack {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                            Button("Retry") {
                                Task {
                                    await viewModel.fetchAvailableManagers()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
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
                                        selectedManager = manager
                                        showDeleteConfirm = true
                                    }
                                )
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                    }
                }

                Button {
                    showAddSheet = true
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
            .navigationTitle("Available Managers")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.fetchAvailableManagers()
            }
            .sheet(isPresented: $showAddSheet) {
                NavigationStack {
                    Form {
                        Section("New Manager Details") {
                            TextField("Username", text: $viewModel.newUsername)
                                .textInputAutocapitalization(.never)
                            TextField("Email", text: $viewModel.newEmail)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                            TextField("Phone", text: $viewModel.newPhone)
                                .keyboardType(.phonePad)
                        }

                        Section {
                            Button {
                                Task {
                                    await viewModel.createManager()
                                    if viewModel.didCreateSuccessfully {
                                        showAddSheet = false
                                    }
                                }
                            } label: {
                                if viewModel.isLoading {
                                    ProgressView()
                                } else {
                                    Text("Create Manager")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!viewModel.canSubmitManagerForm)
                        }
                    }
                    .navigationTitle("Add Manager")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Cancel") { showAddSheet = false }
                        }
                    }
                }
            }
            .alert(
                "Delete Manager?",
                isPresented: $showDeleteConfirm,
                actions: {
                    Button("Cancel", role: .cancel) {}

                    Button("Delete", role: .destructive) {
                        Task {
                            if let manager = selectedManager {
                                await viewModel.deleteManager(manager)
                            }
                            selectedManager = nil
                        }
                    }
                },
                message: {
                    Text("Are you sure you want to delete this manager?")
                }
            )
        }
    }
}
