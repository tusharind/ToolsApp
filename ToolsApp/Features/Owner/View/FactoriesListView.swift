import SwiftUI

struct FactoriesListView: View {
    @StateObject private var viewModel = FactoryViewModel()
    @State private var showAddFactory = false
    @State private var searchText = ""
    
    // Filtered factories based on search
    var filteredFactories: [Factory] {
        if searchText.isEmpty {
            return viewModel.factories
        } else {
            return viewModel.factories.filter { factory in
                factory.name.localizedCaseInsensitiveContains(searchText) ||
                factory.city.localizedCaseInsensitiveContains(searchText) ||
                factory.address.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // MARK: - Factory List
                Group {
                    if viewModel.isLoading && viewModel.factories.isEmpty {
                        ProgressView("Loading factories...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 10) {
                            Text(error)
                                .foregroundColor(.red)
                            Button("Retry") {
                                Task { await viewModel.fetchFactories(page: viewModel.currentPage) }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.factories.isEmpty {
                        VStack {
                            Image(systemName: "building.2")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No factories found.")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredFactories.isEmpty {
                        // Show empty search results
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No results for '\(searchText)'")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Try searching with a different keyword")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredFactories) { factory in
                                NavigationLink(destination: FactoryDetailView(factory: factory)) {
                                    FactoryRowView(factory: factory)
                                }
                                .onAppear {
                                    // Only load more if not searching
                                    if searchText.isEmpty,
                                       factory == viewModel.factories.last,
                                       viewModel.currentPage + 1 < viewModel.totalPages {
                                        Task { await viewModel.fetchFactories(page: viewModel.currentPage + 1) }
                                    }
                                }
                            }
                            
                            // Loading indicator for pagination
                            if viewModel.isLoading && !viewModel.factories.isEmpty {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.fetchFactories(page: 0)
                        }
                    }
                }
            }
            .navigationTitle("Factories")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search factories, cities, or addresses"
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddFactory = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddFactory) {
                AddFactoryView(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchFactories()
            }
        }
    }
}

#Preview {
    FactoriesListView()
}
