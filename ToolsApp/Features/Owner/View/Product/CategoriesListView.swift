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
