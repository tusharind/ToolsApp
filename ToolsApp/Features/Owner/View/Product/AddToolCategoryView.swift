import SwiftUI

struct AddToolCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ToolCategoriesViewModel
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Category Info") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: submitCategory) {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                            } else {
                                Text("Add Category")
                            }
                            Spacer()
                        }
                    }
                    .disabled(isSubmitting || name.isEmpty || description.isEmpty)
                }
            }
            .navigationTitle("New Category")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func submitCategory() {
        isSubmitting = true
        Task {
            let success = await viewModel.createCategory(name: name, description: description)
            isSubmitting = false
            if success {
                dismiss()
            } else {
                errorMessage = viewModel.errorMessage
            }
        }
    }
}
