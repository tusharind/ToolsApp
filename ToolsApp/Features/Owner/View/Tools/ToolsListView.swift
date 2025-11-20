import SwiftUI

struct ToolsListView: View {
    @StateObject private var viewModel = ToolsViewModel()
    @State private var showAddTool = false
    @State private var confirmDelete: ToolItem? = nil

    var body: some View {
        NavigationStack {
            VStack {

                TextField("Search tools…", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .onChange(of: viewModel.searchText) { _, _ in
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

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.tools) { tool in
                            ToolCardView(tool: tool) {
                                confirmDelete = tool
                            }
                            .onAppear {
                                if tool.id == viewModel.tools.last?.id
                                    && !viewModel.isLoading
                                {
                                    viewModel.fetchTools()
                                }
                            }
                        }

                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                }
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
         
            .alert(item: $confirmDelete) { tool in
                Alert(
                    title: Text("Delete Tool"),
                    message: Text(
                        "Are you sure you want to delete \(tool.name)?"
                    ),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteTool(tool.id)
                    },
                    secondaryButton: .cancel()
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


