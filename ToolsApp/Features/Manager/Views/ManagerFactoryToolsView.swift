import SwiftUI

struct ManagerFactoryToolsView: View {
    @StateObject private var viewModel = ManagerFactoryToolsViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredTools) { tool in
                    ToolRowView(tool: tool)
                        .onAppear {
                            if tool == viewModel.tools.last {
                                Task {
                                    await viewModel.fetchTools()
                                }
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
            .searchable(text: $viewModel.searchText, prompt: "Search tools…")
            .navigationTitle("Factory Tools")
            .refreshable {
                await viewModel.fetchTools(reset: true)
            }
            .task {
                await viewModel.fetchTools()
            }
            .alert(
                "Error",
                isPresented: Binding<Bool>(
                    get: { viewModel.errorMessage != nil },
                    set: { _ in viewModel.errorMessage = nil }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

