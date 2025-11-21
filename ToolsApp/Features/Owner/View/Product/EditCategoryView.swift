import SwiftUI

struct EditCategoryView: View {
    @ObservedObject var viewModel: CategoriesViewModel
    let category: CategoryName
    @Binding var isPresented: CategoryName?

    @State private var name: String
    @State private var description: String
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String?

    init(
        viewModel: CategoriesViewModel,
        category: CategoryName,
        isPresented: Binding<CategoryName?>
    ) {
        self.viewModel = viewModel
        self.category = category
        self._isPresented = isPresented
        self._name = State(initialValue: category.categoryName)
        self._description = State(initialValue: category.description)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Category Name") {
                    TextField("Enter category name", text: $name)
                }

                Section("Description") {
                    TextField("Enter description", text: $description)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 4)
                }

                if isProcessing {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("Edit Category")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = nil
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveChanges()
                        }
                    }
                    .disabled(isProcessing)
                }
            }
        }
    }

    @MainActor
    private func saveChanges() async {
        isProcessing = true
        errorMessage = nil

        let success = await viewModel.updateCategory(
            categoryId: category.id,
            name: name,
            description: description
        )

        isProcessing = false

        if success {
            isPresented = nil
        } else {
            errorMessage = viewModel.errorMessage
        }
    }
}
