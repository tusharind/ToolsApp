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
                            ToolCardView(tool: tool)
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

struct ToolCardView: View {
    let tool: ToolItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ToolImageView(url: tool.imageUrl)
                .frame(width: 100, height: 100)
                .cornerRadius(12)
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(tool.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(tool.categoryName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                FlexibleBadgeView(tool: tool)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct FlexibleBadgeView: View {
    let tool: ToolItem

    var badges: [(String, Color)] {
        [
            (tool.type, .purple.opacity(0.6)),
            (
                "Threshold: \(tool.threshold)",
                (tool.threshold < 20 ? Color.red : Color.green).opacity(0.6)
            ),
        ]
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(badges, id: \.0) { text, color in
                    Text(text)
                        .font(.caption2)
                        .bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.2))
                        .foregroundColor(color.opacity(0.8))
                        .cornerRadius(8)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
        .padding(.top, 4)
    }
}

struct ToolImageView: View {
    let url: String

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}
