import SwiftUI

struct ToolCategoriesListView: View {
    @StateObject private var viewModel = ToolCategoriesViewModel()
    @State private var showAddCategory = false
    @State private var showEditCategory: ToolCategory? = nil
    @State private var searchText = ""

    var filteredCategories: [ToolCategory] {
        if searchText.isEmpty {
            return viewModel.categories
        } else {
            return viewModel.categories.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
                    || $0.description.localizedCaseInsensitiveContains(
                        searchText
                    )
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {

                Group {
                    if viewModel.categories.isEmpty && viewModel.isLoading {
                        VStack {
                            Spacer()
                            ProgressView("Loading categories...")
                            Spacer()
                        }
                    } else if filteredCategories.isEmpty {
                        VStack {
                            Spacer()
                            Text("No categories found")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        List(filteredCategories) { category in
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
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("Tool Categories")
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: "Search categories"
                )
                .disableAutocorrection(true)

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
