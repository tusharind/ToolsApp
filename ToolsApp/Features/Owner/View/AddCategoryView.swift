import SwiftUI

struct AddCategoryView: View {
    @ObservedObject var viewModel: CategoriesViewModel
    @Binding var isPresented: Bool
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
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
                        Task {
                            isSubmitting = true
                            let success = await viewModel.addCategory(name: name, description: description)
                            isSubmitting = false
                            if success { isPresented = false }
                        }
                    }
                    .disabled(name.isEmpty || description.isEmpty || isSubmitting)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}
