import SwiftUI

private struct CategoryFilterRow: View {
    @ObservedObject var vm: ProductsViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FactoryButton(
                    title: "All",
                    isSelected: vm.selectedCategoryId == nil
                ) {
                    vm.selectedCategoryId = nil
                    Task { await vm.fetchProducts() }
                }

                ForEach(vm.categories, id: \.id) { cat in
                    FactoryButton(
                        title: cat.categoryName,
                        isSelected: vm.selectedCategoryId == cat.id
                    ) {
                        vm.selectedCategoryId = cat.id
                        Task { await vm.fetchProducts() }
                    }
                }
            }
            .padding(.horizontal)
        }

    }
}

private struct StatusFilterRow: View {
    @ObservedObject var vm: ProductsViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FactoryButton(
                    title: "All",
                    isSelected: vm.selectedStatus == nil
                ) {
                    vm.selectedStatus = nil
                    Task { await vm.fetchProducts() }
                }
                FactoryButton(
                    title: "Active",
                    isSelected: vm.selectedStatus == "ACTIVE"
                ) {
                    vm.selectedStatus = "ACTIVE"
                    Task { await vm.fetchProducts() }
                }
                FactoryButton(
                    title: "Inactive",
                    isSelected: vm.selectedStatus == "INACTIVE"
                ) {
                    vm.selectedStatus = "INACTIVE"
                    Task { await vm.fetchProducts() }
                }
            }
            .padding(.horizontal)
        }
    }
}

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
                    } else if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red).padding()
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

struct ProductRowCard: View {
    let product: Product
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {

                if let urlString = product.image,
                    let url = URL(string: urlString)
                {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty: ProgressView()
                        case .success(let img): img.resizable().scaledToFill()
                        case .failure: placeholderImage
                        @unknown default: placeholderImage
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    placeholderImage
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.headline)
                    if !product.prodDescription.isEmpty {
                        Text(product.prodDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text(product.categoryName)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.blue.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    HStack {
                        Text("₹\(product.price, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Text("\(product.rewardPts) pts")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(4)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        Spacer()
                        Text(product.status.capitalized)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .padding(4)
                            .background(
                                product.status.lowercased() == "active"
                                    ? Color.green
                                    : Color.red
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                    }
                }
                Spacer()
            }

            HStack(spacing: 40) {
                Spacer()
                Button {
                    onEdit()
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
                    .foregroundColor(.green)
                }
                Button {
                    onDelete()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .foregroundColor(.red)
                }
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.1))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
            )
    }
}
