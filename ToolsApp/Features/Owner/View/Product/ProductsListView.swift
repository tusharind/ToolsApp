import SwiftUI

struct ProductsListView: View {
    @StateObject private var viewModel = ProductsViewModel()
    @State private var showAddProduct = false
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 8) {

                TextField("Search products", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    Picker("Category", selection: $viewModel.selectedCategoryId)
                    {
                        Text("All").tag(nil as Int?)
                        Text("Farming").tag(1 as Int?)
                        Text("Electronics").tag(2 as Int?)
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)

                    Picker("Status", selection: $viewModel.selectedStatus) {
                        Text("All").tag(nil as String?)
                        Text("Active").tag("ACTIVE")
                        Text("Inactive").tag("INACTIVE")
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))

            Group {
                if viewModel.isLoading {
                    ProgressView("Loading products...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await viewModel.fetchProducts() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.products.isEmpty {
                    VStack(spacing: 8) {
                        Text("No products available")
                            .foregroundColor(.secondary)
                        Button("Add Product") {
                            showAddProduct = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.products) { product in
                        NavigationLink(
                            destination: ProductDetailView(
                                product: product,
                                viewModel: viewModel
                            )
                        ) {
                            ProductRow(product: product)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .onChange(of: viewModel.searchText) { _ in
                Task { await viewModel.fetchProducts() }
            }
            .onChange(of: viewModel.selectedCategoryId) { _ in
                Task { await viewModel.fetchProducts() }
            }
            .onChange(of: viewModel.selectedStatus) { _ in
                Task { await viewModel.fetchProducts() }
            }
        }
        .navigationTitle("Products")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddProduct = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddProduct) {
            AddProductView(viewModel: viewModel)
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            Task {
                await viewModel.fetchProducts()
            }
        }
    }
}
