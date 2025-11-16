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
                (category.description.localizedCaseInsensitiveContains(viewModel.searchText))
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
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddCategory = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
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
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

struct CategoryRowView: View {
    let category: CategoryName
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.categoryName)
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(category.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "cube.box")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Products: \(category.productCount)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .strokeBorder(Color(.separator), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}
