import SwiftUI

struct AddFactoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FactoryViewModel

    @State private var name = ""
    @State private var city = ""
    @State private var address = ""
    @State private var selectedManagerId: Int? = nil
    @State private var managerSearchText = ""

    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {

                Section("Factory Details") {
                    TextField(
                        "Factory Name",
                        text: $name,
                        prompt: Text("e.g. Alpha Plant")
                    )
                    .autocapitalization(.words)

                    TextField(
                        "City",
                        text: $city,
                        prompt: Text("e.g. San Francisco")
                    )
                    .autocapitalization(.words)

                    TextField(
                        "Address",
                        text: $address,
                        prompt: Text("123 Industrial Rd")
                    )
                    .autocapitalization(.sentences)
                }

                Section("Assign Manager") {
                    if viewModel.isLoadingManagers {
                        HStack {
                            ProgressView()
                            Text("Loading managers...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else if let error = viewModel.managersErrorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                error,
                                systemImage: "exclamationmark.triangle"
                            )
                            .foregroundColor(.red)
                            .font(.caption)

                            Button("Retry") {
                                Task {
                                    await viewModel.fetchAvailableManagers()
                                }
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                    } else {

                        TextField("Search manager...", text: $managerSearchText)
                            .textFieldStyle(.roundedBorder)
                            .disableAutocorrection(true)
                            .onChange(of: managerSearchText) { _, newValue in
                                Task {
                                    await viewModel.searchManagers(
                                        query: newValue
                                    )
                                }
                            }

                        if viewModel.availableManagers.isEmpty {
                            Text("No managers found")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ManagerSelectionList(
                                managers: viewModel.availableManagers,
                                selectedId: $selectedManagerId
                            )
                        }
                    }
                }

                Section {
                    Button {
                        Task { await createFactory() }
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(
                                isSubmitting ? "Creating..." : "Create Factory"
                            )
                            .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(isSubmitting || !isFormValid)
                    .listRowBackground(
                        isFormValid
                            ? Color.accentColor : Color.gray.opacity(0.3)
                    )
                    .foregroundColor(.white)
                    .animation(.easeInOut, value: isFormValid)
                }
            }
            .navigationTitle("Add Factory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.blue)
                }
            }
            .alert("Result", isPresented: $showAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text(alertMessage)
            }
            .task {
                await viewModel.fetchAvailableManagers()
            }
        }
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !city.trimmingCharacters(in: .whitespaces).isEmpty
            && !address.trimmingCharacters(in: .whitespaces).isEmpty
            && selectedManagerId != nil
    }

    private func createFactory() async {
        isSubmitting = true
        defer { isSubmitting = false }

        guard let managerId = selectedManagerId else {
            alertMessage = "Please select a manager"
            showAlert = true
            return
        }

        let request = CreateFactoryRequest(
            name: name,
            city: city,
            address: address,
            plantHeadId: managerId
        )

        let success = await viewModel.createFactory(request)
        alertMessage =
            success
            ? "Factory created successfully!"
            : "Failed to create factory. Please try again."
        showAlert = true
    }
}

#Preview {
    AddFactoryView(viewModel: FactoryViewModel())
}
