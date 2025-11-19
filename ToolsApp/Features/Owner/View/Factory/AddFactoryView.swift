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

    @State private var nameTouched = false
    @State private var cityTouched = false
    @State private var addressTouched = false
    @State private var managerTouched = false

    var body: some View {
        NavigationStack {
            Form {

                Section("Factory Details") {
                    VStack(alignment: .leading) {
                        TextField("Factory Name", text: $name)
                            .autocapitalization(.words)
                            .onChange(of: name) { oldValue,newValue in nameTouched = true }

                        if nameTouched, let error = nameError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    VStack(alignment: .leading) {
                        TextField("City", text: $city)
                            .autocapitalization(.words)
                            .onChange(of: city) { oldValue,newValue in cityTouched = true }

                        if cityTouched, let error = cityError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    VStack(alignment: .leading) {
                        TextField("Address", text: $address)
                            .autocapitalization(.sentences)
                            .onChange(of: address) { oldValue,newValue in addressTouched = true }

                        if addressTouched, let error = addressError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }
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
                            Label(error, systemImage: "exclamationmark.triangle")
                                .foregroundColor(.red)
                                .font(.caption)

                            Button("Retry") {
                                Task { await viewModel.fetchAvailableManagers() }
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                    } else {
                        TextField("Search manager...", text: $managerSearchText)
                            .textFieldStyle(.roundedBorder)
                            .disableAutocorrection(true)
                            .onChange(of: managerSearchText) { oldValue,newValue in
                                managerTouched = true
                                Task { await viewModel.searchManagers(query: managerSearchText) }
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
                            .onChange(of: selectedManagerId) { oldValue,newValue in managerTouched = true }
                        }

                        if managerTouched, let error = managerError {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }
                }

                Section {
                    Button {
                        Task { await createFactory() }
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView().progressViewStyle(.circular)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(isSubmitting ? "Creating..." : "Create Factory")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(isSubmitting || !isFormValid)
                    .listRowBackground(isFormValid ? Color.accentColor : Color.gray.opacity(0.3))
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
            .task { await viewModel.fetchAvailableManagers() }
        }
    }

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedCity: String { city.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedAddress: String { address.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var nameError: String? {
        let regex = "^[A-Za-z ]+$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        if trimmedName.isEmpty { return "Name cannot be empty" }
        if !test.evaluate(with: trimmedName) { return "Name can contain letters and spaces only" }
        return nil
    }

    private var cityError: String? {
        let regex = "^[A-Za-z ]+$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        if trimmedCity.isEmpty { return "City cannot be empty" }
        if !test.evaluate(with: trimmedCity) { return "City can contain letters and spaces only" }
        return nil
    }

    private var addressError: String? {
        let regex = "^[A-Za-z0-9 ,.-]+$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        if trimmedAddress.isEmpty { return "Address cannot be empty" }
        if !test.evaluate(with: trimmedAddress) {
            return "Address can contain letters, numbers, commas, periods, and hyphens"
        }
        return nil
    }

    private var managerError: String? {
        selectedManagerId == nil ? "Please select a manager" : nil
    }

    private var isFormValid: Bool {
        nameError == nil && cityError == nil && addressError == nil && managerError == nil
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
            name: trimmedName,
            city: trimmedCity,
            address: trimmedAddress,
            plantHeadId: managerId
        )

        let success = await viewModel.createFactory(request)
        alertMessage = success ? "Factory created successfully!" : "Failed to create factory. Please try again."
        showAlert = true
    }
}

#Preview {
    AddFactoryView(viewModel: FactoryViewModel())
}

