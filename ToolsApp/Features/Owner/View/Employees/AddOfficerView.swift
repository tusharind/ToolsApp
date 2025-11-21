import SwiftUI

struct AddOfficerView: View {
    let office: CentralOffice
    @ObservedObject var viewModel: CentralOfficerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Officer Details") {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Name", text: $viewModel.name)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                        if let error = viewModel.nameError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        if let error = viewModel.emailError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Phone", text: $viewModel.phone)
                            .keyboardType(.numberPad)
                        if let error = viewModel.phoneError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }
                }

                if let generalError = viewModel.errorMessage {
                    Text(generalError)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Section {
                    Button {
                        Task {
                            let success = await viewModel.addOfficer(
                                to: office.id
                            )
                            if success { dismiss() }
                        }
                    } label: {
                        HStack {
                            if viewModel.isSubmitting {
                                ProgressView().progressViewStyle(.circular)
                                Text("Adding...").padding(.leading, 4)
                            } else {
                                Text("Add Officer")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
            .navigationTitle("Add Officer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
