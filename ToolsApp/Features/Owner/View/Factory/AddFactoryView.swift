import SwiftUI

struct AddFactoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FactoryViewModel

    var body: some View {
        NavigationStack {
            Form {

                Section("Factory Details") {
                    VStack(alignment: .leading) {
                        TextField("Factory Name", text: $viewModel.name)
                            .autocapitalization(.words)
                            .onChange(of: viewModel.name) {
                                oldValue,
                                newValue in
                                viewModel.nameTouched = true
                            }

                        if viewModel.nameTouched,
                            let error = viewModel.nameError
                        {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    VStack(alignment: .leading) {
                        TextField("City", text: $viewModel.city)
                            .autocapitalization(.words)
                            .onChange(of: viewModel.city) {
                                oldValue,
                                newValue in
                                viewModel.cityTouched = true
                            }

                        if viewModel.cityTouched,
                            let error = viewModel.cityError
                        {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }

                    VStack(alignment: .leading) {
                        TextField("Address", text: $viewModel.address)
                            .autocapitalization(.sentences)
                            .onChange(of: viewModel.address) {
                                oldValue,
                                newValue in
                                viewModel.addressTouched = true
                            }

                        if viewModel.addressTouched,
                            let error = viewModel.addressError
                        {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }
                }

                Section("Assign Manager") {
                    if viewModel.isLoadingManagers {
                        HStack {
                            ProgressView()
                            Text("Loading managers...").foregroundColor(
                                .secondary
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else if let error = viewModel.managersErrorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                error,
                                systemImage: "exclamationmark.triangle"
                            )
                            .foregroundColor(.red).font(.caption)

                            Button("Retry") {
                                Task {
                                    await viewModel.fetchAvailableManagers()
                                }
                            }
                            .font(.caption).buttonStyle(.bordered)
                        }
                    } else {
                        TextField(
                            "Search manager...",
                            text: $viewModel.managerSearchText
                        )
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.managerSearchText) {
                            oldValue,
                            newValue in
                            viewModel.managerTouched = true
                        }

                        if viewModel.availableManagers.isEmpty {
                            Text("No managers found")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ManagerSelectionList(
                                managers: viewModel.availableManagers,
                                selectedId: $viewModel.selectedManagerId
                            )
                            .onChange(of: viewModel.selectedManagerId) {
                                oldValue,
                                newValue in
                                viewModel.managerTouched = true
                            }
                        }

                        if viewModel.managerTouched,
                            let error = viewModel.managerError
                        {
                            Text(error).foregroundColor(.red).font(.caption)
                        }
                    }
                }

                Section {
                    Button {
                        Task { await viewModel.createFactory() }
                    } label: {
                        HStack {
                            if viewModel.isSubmitting {
                                ProgressView().progressViewStyle(.circular)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(
                                viewModel.isSubmitting
                                    ? "Creating..." : "Create Factory"
                            )
                            .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                    .listRowBackground(
                        viewModel.isFormValid
                            ? Color.accentColor : Color.gray.opacity(0.3)
                    )
                    .foregroundColor(.white)
                    .animation(.easeInOut, value: viewModel.isFormValid)
                }
            }
            .navigationTitle("Add Factory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundColor(.blue)
                }
            }
            .alert("Result", isPresented: $viewModel.showAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text(viewModel.alertMessage)
            }
            .task { await viewModel.fetchAvailableManagers() }
        }
    }
}

#Preview {
    AddFactoryView(viewModel: FactoryViewModel())
}
