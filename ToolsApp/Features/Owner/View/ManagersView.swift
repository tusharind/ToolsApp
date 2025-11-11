import SwiftUI

struct ManagersView: View {
    @StateObject private var viewModel = ManagersViewModel()
    
    @State private var showingAddManager = false
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                
                VStack {
                    // MARK: - Search Bar
                    TextField("Search managers...", text: $searchText)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .onChange(of: searchText) { newValue in
                            // Cancel previous task if user types again
                            searchTask?.cancel()
                            
                            // Debounce for 0.5 seconds
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 900_000_000) // 0.5 sec
                                if !Task.isCancelled {
                                    await viewModel.fetchManagers(search: newValue)
                                }
                            }
                        }
                    
                    // MARK: - Main List
                    VStack{
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
                                    Task { await viewModel.fetchManagers(search: searchText) }
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
                                            await viewModel.fetchManagers(search: searchText)
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
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ManagerCardView: View {
    let manager: Manager
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            // MARK: - Profile Image (if available)
            if let imgUrl = manager.profileImage ?? manager.img,
               let url = URL(string: imgUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 60, height: 60)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }
            
            // MARK: - Manager Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(manager.username)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                    
                    Text(manager.status)
                        .font(.caption)
                        .padding(4)
                        .background(statusColor(manager.status).opacity(0.2))
                        .foregroundColor(statusColor(manager.status))
                        .cornerRadius(6)
                }
                
                Text(manager.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack(spacing: 10) {
                    Label(manager.role, systemImage: "person.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                if let factoryName = manager.factoryName {
                    Text("Factory: \(factoryName)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 130) // Fixed height for uniformity
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Helper Functions
    
    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "inactive": return .red
        case "pending": return .orange
        default: return .blue
        }
    }
    
    func formattedDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .short
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

