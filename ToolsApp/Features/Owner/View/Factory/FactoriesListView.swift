import SwiftUI

struct FactoriesListView: View {
    @StateObject private var viewModel = FactoryViewModel()
    @State private var showAddFactory = false
    @State private var cityFilter: String = ""

    var body: some View {
        VStack {
  
            VStack(spacing: 8) {
                TextField(
                    "Search factories, cities, or addresses",
                    text: $viewModel.searchText
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            }

            Divider()

            Group {
                if viewModel.isLoading && viewModel.factories.isEmpty {
                    ProgressView("Loading factories...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchFactories(
                                    page: viewModel.currentPage
                                )
                            }
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
                } else {
                    List {
                        ForEach(viewModel.factories) { factory in
                            NavigationLink(
                                destination: FactoryDetailView(
                                    factory: factory,
                                    viewModel: viewModel
                                )
                            ) {
                                FactoryRowView(factory: factory)
                            }
                            .onAppear {
                                if factory == viewModel.factories.last,
                                    viewModel.currentPage + 1
                                        < viewModel.totalPages
                                {
                                    Task {
                                        await viewModel.fetchFactories(
                                            page: viewModel.currentPage + 1
                                        )
                                    }
                                }
                            }
                        }

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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Section("Sort By") {
                        Picker("Sort By", selection: $viewModel.sortBy) {
                            ForEach(SortBy.allCases) { sort in
                                Text(sort.displayName).tag(sort)
                            }
                        }
                    }

                    Section("Sort Direction") {
                        Picker("Direction", selection: $viewModel.sortDirection)
                        {
                            ForEach(SortDirection.allCases) { dir in
                                Text(dir.displayName).tag(dir)
                            }
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddFactory = true
                } label: {
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
        .onAppear {
            cityFilter = viewModel.selectedCity ?? ""
        }
    }
}
