import SwiftUI

struct CategoriesListView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var showAddCategory = false
    @State private var showEditCategory: CategoryName? = nil

    var filteredCategories: [CategoryName] {
        if viewModel.searchText.isEmpty {
            return viewModel.categories
        } else {
            return viewModel.categories.filter { category in
                category.categoryName.localizedCaseInsensitiveContains(
                    viewModel.searchText
                )
                    || category.description.localizedCaseInsensitiveContains(
                        viewModel.searchText
                    )
            }
        }
    }

    var isInitialLoading: Bool {
        viewModel.isLoading && viewModel.categories.isEmpty
    }

    var hasError: Bool {
        viewModel.errorMessage != nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                TextField("Search categories", text: $viewModel.searchText)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                if isInitialLoading {
                    Spacer()
                    ProgressView("Loading categories...")
                        .padding()
                    Spacer()
                } else if hasError {
                    Spacer()
                    Text(viewModel.errorMessage ?? "")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else if filteredCategories.isEmpty {
                    Spacer()
                    Text("No categories found")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    categoriesListContent
                }
            }
            .navigationTitle("Product Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCategory = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView(
                    viewModel: viewModel,
                    isPresented: $showAddCategory
                )
            }
            .sheet(item: $showEditCategory) { category in
                EditCategoryView(
                    viewModel: viewModel,
                    category: category,
                    isPresented: $showEditCategory
                )
            }
            .task {
                await viewModel.fetchCategories()
            }
        }
    }

    var categoriesListContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredCategories) { category in
                    CategoryRowView(category: category) {
                        showEditCategory = category
                    }
                    .onAppear {
                        if category == viewModel.categories.last {
                            Task { await viewModel.fetchCategories() }
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct CategoryRowView: View {
    let category: CategoryName
    var onEdit: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text(category.categoryName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(category.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Image(systemName: "cube.box")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Products: \(category.productCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.05),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )

            if let onEdit = onEdit {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .padding(10)
                }
                .padding(8)
            }
        }
        .padding(.horizontal, 8)
    }
}

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
