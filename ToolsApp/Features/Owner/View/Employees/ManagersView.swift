import SwiftUI

struct ManagersView: View {
    @StateObject private var viewModel = ManagersViewModel()

    @State private var showingAddManager = false
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var searchTask: Task<Void, Never>? = nil

    @State private var usernameTouched = false
    @State private var emailTouched = false
    @State private var phoneTouched = false

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
            .onChange(of: viewModel.searchText) { _, _ in
                searchTask?.cancel()
                searchTask = Task {
                    try? await Task.sleep(nanoseconds: 900_000_000)
                    if !Task.isCancelled {
                        await viewModel.fetchManagers()
                    }
                }
            }
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
                ManagerCardView(manager: manager)
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
            Button("Retry") { Task { await viewModel.fetchManagers() } }
                .buttonStyle(.borderedProminent)
            Spacer()
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
                    ValidatedTextField(
                        title: "Username",
                        text: $username,
                        touched: $usernameTouched,
                        errorMessage: "Username cannot be empty"
                    )
                    ValidatedTextField(
                        title: "Email",
                        text: $email,
                        touched: $emailTouched,
                        keyboard: .emailAddress,
                        errorMessage: "Enter a valid email",
                        validator: { text in
                            let emailRegex =
                                "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                            return NSPredicate(
                                format: "SELF MATCHES %@",
                                emailRegex
                            ).evaluate(with: text)
                        }
                    )
                    ValidatedTextField(
                        title: "Phone",
                        text: $phone,
                        touched: $phoneTouched,
                        keyboard: .phonePad,
                        errorMessage: "Enter a valid phone number",
                        validator: { text in
                            let phoneRegex = "^[0-9]{7,15}$"
                            return NSPredicate(
                                format: "SELF MATCHES %@",
                                phoneRegex
                            ).evaluate(with: text)
                        }
                    )
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
                                resetForm()
                                showingAddManager = false
                                await viewModel.fetchManagers()
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
                    .disabled(!isFormValid || viewModel.isLoading)
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

    private func resetForm() {
        username = ""
        email = ""
        phone = ""
        usernameTouched = false
        emailTouched = false
        phoneTouched = false
    }

    private var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !phone.isEmpty
            && usernameError == nil && emailError == nil && phoneError == nil
    }

    private var usernameError: String? {
        usernameTouched && username.trimmingCharacters(in: .whitespaces).isEmpty
            ? "Username cannot be empty" : nil
    }

    private var emailError: String? {
        guard emailTouched else { return nil }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(
            with: email
        ) ? nil : "Enter a valid email"
    }

    private var phoneError: String? {
        guard phoneTouched else { return nil }
        let phoneRegex = "^[0-9]{7,15}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(
            with: phone
        ) ? nil : "Enter a valid phone number"
    }
}

struct ValidatedTextField: View {
    let title: String
    @Binding var text: String
    @Binding var touched: Bool
    var keyboard: UIKeyboardType = .default
    var errorMessage: String
    var validator: ((String) -> Bool)? = nil

    var body: some View {
        VStack(alignment: .leading) {
            TextField(title, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .onChange(of: text) { oldValue, inValue in touched = true }
            if touched && !isValid {
                Text(errorMessage).foregroundColor(.red).font(.caption)
            }
        }
    }

    private var isValid: Bool {
        validator?(text) ?? !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

struct ManagerCardView: View {
    let manager: Manager

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            profileImage
            managerInfo
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
    }

    private var profileImage: some View {
        Group {
            if let urlString = manager.profileImage ?? manager.img,
                let url = URL(string: urlString)
            {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 60, height: 60)
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    case .failure:
                        defaultImage
                    @unknown default:
                        defaultImage
                    }
                }
            } else {
                defaultImage
            }
        }
    }

    private var defaultImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundColor(.gray)
    }

    private var managerInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(manager.username)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                Text(manager.status.capitalized)
                    .font(.caption)
                    .padding(4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(6)
            }

            Text(manager.email)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
                .truncationMode(.tail)

            if let factoryName = manager.factoryName {
                Text("Factory: \(factoryName)")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(factoryBadgeBackground)
            }
        }
    }

    private var statusColor: Color {
        switch manager.status.lowercased() {
        case "active": return .green
        case "inactive": return .red
        case "pending": return .orange
        default: return .blue
        }
    }

    private var factoryBadgeBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.orange)
            .shadow(color: Color.orange.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}
