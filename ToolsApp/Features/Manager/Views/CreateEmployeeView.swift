import SwiftUI

struct CreateEmployeeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateEmployeeViewModel()

    var onEmployeeCreated: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                Section("Employee Info") {
                    TextField("Username", text: $viewModel.username)
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $viewModel.phone)
                        .keyboardType(.phonePad)

                    Picker("Role", selection: $viewModel.role) {
                        ForEach(viewModel.roles, id: \.self) { role in
                            Text(role.capitalized)
                        }
                    }

                    TextField(
                        "Bay ID",
                        value: $viewModel.bayId,
                        format: .number
                    )
                }

                Section {
                    Button {
                        Task {
                            await viewModel.createEmployee()
                            if viewModel.successMessage != nil {
                                onEmployeeCreated?()
                                dismiss() 
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Create Employee")
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }

                if let success = viewModel.successMessage {
                    Section {
                        Text(success)
                            .foregroundColor(.green)
                    }
                }

                Section {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Label(
                            "Back to Employee List",
                            systemImage: "arrow.left.circle.fill"
                        )
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Create Employee")
        }
    }
}
