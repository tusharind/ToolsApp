import SwiftUI

struct AvailableManagersView: View {
    @StateObject private var viewModel = ManagersViewModel()

    @State private var showingAddManager = false
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var searchTask: Task<Void, Never>? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    TextField("Search managers...", text: $viewModel.searchText)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onChange(of: viewModel.searchText) {
                            newValue,
                            oldValue in
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
                            VStack {
                                Spacer()
                                ProgressView("Loading managers...")
                                Spacer()
                            }
                        } else if let error = viewModel.errorMessage {
                            VStack {
                                Spacer()
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
                                Spacer()
                            }
                        } else if viewModel.availableManagers.isEmpty {
                            VStack {
                                Spacer()
                                Text("No managers found")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        } else {
                            List {
                                ForEach(viewModel.availableManagers) {
                                    manager in
                                    ManagerCardView(manager: manager)
                                        .listRowSeparator(.hidden)
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                }

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
                .sheet(isPresented: $showingAddManager) {
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
                                            await viewModel
                                                .fetchAvailableManagers()
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
                                .disabled(
                                    username.isEmpty || email.isEmpty
                                        || phone.isEmpty
                                )
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
            .navigationTitle("Available Managers")
            .navigationBarTitleDisplayMode(.inline)

            .onAppear {
                Task { await viewModel.fetchAvailableManagers() }
            }
        }
    }
}
