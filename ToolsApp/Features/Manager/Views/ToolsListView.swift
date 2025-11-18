import SwiftUI

struct ToolsListView: View {
    @StateObject private var viewModel = ToolsViewModel()
    @State private var showAddTool = false

    var body: some View {
        NavigationStack {
            VStack {

                TextField("Search tools…", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .onChange(of: viewModel.searchText) { oldValue, newValue in
                        viewModel.onSearchChanged()
                    }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {

                        categoryChip(
                            title: "All",
                            isSelected: viewModel.selectedCategoryId == nil
                        ) {
                            viewModel.selectCategory(nil)
                        }

                        ForEach(viewModel.categories) { category in
                            categoryChip(
                                title: category.name,
                                isSelected: viewModel.selectedCategoryId
                                    == category.id
                            ) {
                                viewModel.selectCategory(category.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }

                List {
                    ForEach(viewModel.tools) { tool in
                        HStack(spacing: 12) {

                            AsyncImage(url: URL(string: tool.imageUrl)) { img in
                                img.resizable()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 55, height: 55)
                            .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(tool.name)
                                    .font(.headline)

                                Text(tool.categoryName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text("Type: \(tool.type)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onAppear {
                            if tool.id == viewModel.tools.last?.id {
                                viewModel.fetchTools()
                            }
                        }
                    }

                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTool.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTool) {
                CreateToolView()
            }
            .alert(
                item: Binding(
                    get: {
                        viewModel.errorMessage.map { ErrorMessage(text: $0) }
                    },
                    set: { _ in viewModel.errorMessage = nil }
                )
            ) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.text),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    @ViewBuilder
    func categoryChip(
        title: String,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Text(title)
            .font(.subheadline)
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(16)
            .onTapGesture { onTap() }
    }
}

