import SwiftUI

struct AddFactoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FactoryViewModel

    @State private var name: String = ""
    @State private var city: String = ""
    @State private var address: String = ""
    @State private var selectedManagerId: Int? = nil
    @State private var managerSearchText: String = ""

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
                }

                Section("Assign Manager") {
                    if viewModel.isLoadingManagers {
                        ProgressView("Loading managers...")
                    } else if let error = viewModel.managersErrorMessage {
                        VStack(alignment: .leading) {
                            Text(error).foregroundColor(.red)
                            Button("Retry") {
                                Task {
                                    await viewModel.fetchAvailableManagers()
                                }
                            }
                        }
                    } else {

                        TextField("Search manager...", text: $managerSearchText)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: managerSearchText) { newValue in
                                Task {

                                    await viewModel.searchManagers(
                                        query: newValue
                                    )

                                }
                            }

                        if viewModel.availableManagers.isEmpty {
                            Text("No managers found.").foregroundColor(.gray)
                        } else {
                            ScrollView {
                                ForEach(viewModel.availableManagers) {
                                    manager in
                                    HStack {
                                        Text(manager.username)
                                        Spacer()
                                        if selectedManagerId == manager.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedManagerId = manager.id
                                    }
                                }
                            }
                        }
                    }
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
                    .disabled(
                        isSubmitting || name.isEmpty || city.isEmpty
                            || address.isEmpty || selectedManagerId == nil
                    )
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
            .task {
                await viewModel.fetchAvailableManagers()
            }
        }
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
            ? "Factory created successfully!" : "Failed to create factory."
        showAlert = true
    }
}

#Preview {
    AddFactoryView(viewModel: FactoryViewModel())
}
