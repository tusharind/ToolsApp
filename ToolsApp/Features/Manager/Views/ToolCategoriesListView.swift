import SwiftUI

struct ToolCategoriesListView: View {
    @StateObject private var viewModel = ToolCategoriesViewModel()
    @State private var showAddCategory = false
    @State private var showEditCategory: ToolCategory? = nil 

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.categories.isEmpty && viewModel.isLoading {
                    ProgressView("Loading categories...")
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.categories) { category in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(category.name)
                                        .font(.headline)
                                    Text(category.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button {
                                    showEditCategory = category
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Tool Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCategory.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddToolCategoryView(viewModel: viewModel)
            }
            .sheet(item: $showEditCategory) { category in
                EditToolCategoryView(category: category, viewModel: viewModel)
            }
            .task {
                await viewModel.fetchCategories()
            }
        }
    }
}

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
