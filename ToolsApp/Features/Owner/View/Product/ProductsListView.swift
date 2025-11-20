import SwiftUI

struct ProductsListView: View {
    @StateObject private var viewModel = ProductsViewModel()
    @State private var showAddProduct = false
    @State private var selectedProduct: Product? = nil
    @State private var isShowingEditSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                searchBar

                VStack(alignment: .leading, spacing: 10) {
                    CategoryFilterRow(vm: viewModel)
                    StatusFilterRow(vm: viewModel)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)

                VStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView("Loading products…").padding()
                    } else if viewModel.products.isEmpty {
                        emptyView
                    } else {
                        ForEach(viewModel.products, id: \.id) { product in
                            ProductRowCard(
                                product: product,
                                onEdit: {
                                    selectedProduct = product
                                    isShowingEditSheet = true
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteProduct(
                                            id: product.id
                                        )
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .task {
            await viewModel.fetchProducts()
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
        .sheet(isPresented: $isShowingEditSheet) {
            if let product = selectedProduct {
                EditProductView(product: product, viewModel: viewModel) {
                    updatedProduct in
                    if let index = viewModel.products.firstIndex(where: {
                        $0.id == updatedProduct.id
                    }) {
                        viewModel.products[index] = updatedProduct
                    }
                    selectedProduct = updatedProduct
                    isShowingEditSheet = false
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search products", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .disableAutocorrection(true)
                .autocapitalization(.none)
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(
                        .gray
                    )
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .onChange(of: viewModel.searchText) { _, _ in
            Task { await viewModel.fetchProducts() }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            Text("No products found").foregroundColor(.secondary)
            Button("Add Product") { showAddProduct = true }
                .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}
