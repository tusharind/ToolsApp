import SwiftUI

struct AddCategoryView: View {
    @ObservedObject var viewModel: CategoriesViewModel
    @Binding var isPresented: Bool

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                        .onChange(of: name) { oldValue, newValue in

                            let filtered = newValue.filter { !$0.isNumber }
                            if filtered != newValue {
                                name = filtered
                                alertMessage =
                                    "Numbers are not allowed in Name."
                                showAlert = true
                            }
                        }

                    TextField("Description", text: $description)
                        .autocapitalization(.sentences)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Category")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedName = name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        let trimmedDescription = description.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )

                        if trimmedName.isEmpty || trimmedDescription.isEmpty {
                            alertMessage =
                                "Fields cannot be empty or just spaces."
                            showAlert = true
                            return
                        }

                        Task {
                            isSubmitting = true
                            let success = await viewModel.addCategory(
                                name: trimmedName,
                                description: trimmedDescription
                            )
                            isSubmitting = false
                            if success { isPresented = false }
                        }
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                            || description.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty || isSubmitting
                    )
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
