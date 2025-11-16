import SwiftUI

struct ToolCategoriesListView: View {
    @StateObject private var viewModel = ToolCategoriesViewModel()
    @State private var showAddCategory = false

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.categories.isEmpty && viewModel.isLoading {
                    ProgressView("Loading categories...")
                        .padding()
                } else {
                    List(viewModel.categories) { category in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.name)
                                .font(.headline)
                            Text(category.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
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
            .task {
                await viewModel.fetchCategories()
            }
        }
    }
}
