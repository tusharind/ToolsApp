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
            ZStack(alignment: .bottomTrailing) {

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
                    } else if filteredCategories.isEmpty {
                        Spacer()
                        Text("No categories found")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        categoriesListContent
                    }
                }

                Button(action: { showAddCategory = true }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Product Categories")
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
