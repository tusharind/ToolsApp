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
            VStack(spacing: 12) {
                
                // MARK: - Search Bar
                TextField("Search categories", text: $viewModel.searchText)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // MARK: - Content
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
                            .font(.title2)
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
    
    // MARK: - Categories Scroll List
    var categoriesListContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredCategories) { category in
                    CategoryRowView(category: category)
                        .frame(maxWidth: .infinity)
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
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Category Card
struct CategoryRowView: View {
    let category: CategoryName
    
    private var backgroundColor: Color {
        let colors: [Color] = [
            Color(red: 0.95, green: 0.97, blue: 1.0),
            Color(red: 0.97, green: 0.95, blue: 1.0),
            Color(red: 0.95, green: 1.0, blue: 0.95),
            Color(red: 1.0, green: 0.96, blue: 0.95)
        ]
        let index = abs(category.id.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(category.categoryName)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
             let description = category.description
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            
            Text("Products: \(category.productCount)")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

