import SwiftUI

struct ManagersView: View {
    @StateObject private var viewModel = ManagersViewModel()
    
    @State private var showingAddManager = false
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                
                // MARK: - Main List
                Group {
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
                                Task { await viewModel.fetchManagers() }
                            }
                            .buttonStyle(.borderedProminent)
                            Spacer()
                        }
                    } else if viewModel.managers.isEmpty {
                        VStack {
                            Spacer()
                            Text("No managers found")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(viewModel.managers) { manager in
                                ManagerCardView(manager: manager)
                                    .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .task {
                    await viewModel.fetchManagers()
                }
                
                // MARK: - Floating Add Button
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
                                            await viewModel.fetchManagers()
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
            .navigationTitle("Managers")
        }
    }
}

struct ManagerCardView: View {
    let manager: Manager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(manager.username)
                .font(.headline)
            Text(manager.email)
                .font(.subheadline)
                .foregroundColor(.gray)
             let status = manager.status
                Text(status)
                    .font(.caption)
                    .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

