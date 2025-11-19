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
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
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
                    .disabled(isSubmitting || !isValidInput())
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
    
    private func isValidInput() -> Bool {

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let nameRegex = "^[A-Za-z ]+$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        guard nameTest.evaluate(with: trimmedName) else { return false }
        
        guard !trimmedDescription.isEmpty else { return false }
        
        return true
    }
    
    private func submitCategory() {
        isSubmitting = true
        errorMessage = nil
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            let success = await viewModel.createCategory(name: trimmedName, description: trimmedDescription)
            isSubmitting = false
            if success {
                dismiss()
            } else {
                errorMessage = viewModel.errorMessage
            }
        }
    }
}

