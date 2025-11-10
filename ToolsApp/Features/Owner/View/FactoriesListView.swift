import SwiftUI

struct FactoriesListView: View {
    @StateObject private var viewModel = FactoryViewModel()
    @State private var showAddFactory = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading factories...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 10) {
                    Text(error)
                        .foregroundColor(.red)
                    Button("Retry") {
                        Task { await viewModel.fetchFactories() }
                    }
                }
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
                List(viewModel.factories) { factory in
                    NavigationLink(
                        destination: FactoryDetailView(factory: factory)
                    ) {
                        FactoryRowView(factory: factory)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.fetchFactories()
                }
            }
        }
        .navigationTitle("Factories")
        .toolbar {
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
    }
}

// MARK: - Preview
#Preview {
    FactoriesListView()
}
