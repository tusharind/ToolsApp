import SwiftUI

struct CategoriesListView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var showAddCategory = false
    
    var filteredCategories: [CategoryName] {
        if viewModel.searchText.isEmpty {
            return viewModel.categories
        } else {
            return viewModel.categories.filter { category in
                category.categoryName.localizedCaseInsensitiveContains(viewModel.searchText) ||
                (category.description.localizedCaseInsensitiveContains(viewModel.searchText) )
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
            VStack {
                TextField("Search categories", text: $viewModel.searchText)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                if isInitialLoading {
                    ProgressView("Loading categories...")
                        .padding()
                } else if hasError {
                    Text(viewModel.errorMessage ?? "")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    categoriesListContent
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCategory = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView(viewModel: viewModel, isPresented: $showAddCategory)
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
                    CategoryRowView(category: category)
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
            .padding()
        }
    }
}

struct CategoryRowView: View {
    let category: CategoryName
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(category.categoryName)
                .font(.headline)
            Text(category.description ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Products: \(category.productCount)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}
