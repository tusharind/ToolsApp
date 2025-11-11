import SwiftUI

struct AddFactoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FactoryViewModel

    @State private var name: String = ""
    @State private var city: String = ""
    @State private var address: String = ""
    @State private var plantHeadId: String = ""

    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Factory Details") {
                    TextField("Factory Name", text: $name)
                    TextField("City", text: $city)
                    TextField("Address", text: $address)
                    TextField("Plant Head ID", text: $plantHeadId)
                        .keyboardType(.numberPad)
                }

                Section {
                    Button {
                        Task { await createFactory() }
                    } label: {
                        if isSubmitting {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Create Factory").frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSubmitting || name.isEmpty || city.isEmpty || address.isEmpty || plantHeadId.isEmpty)
                }
            }
            .navigationTitle("Add Factory")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Result", isPresented: $showAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func createFactory() async {
        isSubmitting = true
        defer { isSubmitting = false }

        guard let headId = Int(plantHeadId) else {
            alertMessage = "Invalid Plant Head ID"
            showAlert = true
            return
        }

        let request = CreateFactoryRequest(name: name, city: city, address: address, plantHeadId: headId)
        let success = await viewModel.createFactory(request)

        alertMessage = success ? "Factory created successfully!" : "Failed to create factory."
        showAlert = true
    }
}

