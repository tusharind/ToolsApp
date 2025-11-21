import SwiftUI

struct EditToolCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State var name: String
    @State var description: String

    let category: ToolCategory
    @ObservedObject var viewModel: ToolCategoriesViewModel
    @State private var isSubmitting = false

    init(category: ToolCategory, viewModel: ToolCategoriesViewModel) {
        self.category = category
        self.viewModel = viewModel
        _name = State(initialValue: category.name)
        _description = State(initialValue: category.description)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }

                Section {
                    Button {
                        Task {
                            isSubmitting = true
                            let success = await viewModel.updateCategory(
                                id: category.id,
                                name: name,
                                description: description
                            )
                            isSubmitting = false
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Update Category")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
            .navigationTitle("Edit Category")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
