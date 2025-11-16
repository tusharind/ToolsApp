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
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 10) {

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search products", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)

                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    CategoryFilterRow(vm: viewModel)
                    StatusFilterRow(vm: viewModel)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
            .background(Color(UIColor.systemBackground))
            .overlay(Divider(), alignment: .bottom)
            .zIndex(1)

            Group {
                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading products...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 30))
                        Text(error)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await viewModel.fetchProducts() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.products.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "shippingbox.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 32))
                        Text("No products found")
                            .foregroundColor(.secondary)
                        Button("Add Product") {
                            showAddProduct = true
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.products) { product in
                        NavigationLink {
                            ProductDetailView(
                                product: product,
                                viewModel: viewModel
                            )
                        } label: {
                            ProductRow(product: product)
                                .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .onChange(of: viewModel.searchText) { _, _ in
                Task { await viewModel.fetchProducts() }
            }
            .onChange(of: viewModel.selectedCategoryId) { _, _ in
                Task { await viewModel.fetchProducts() }
            }
            .onChange(of: viewModel.selectedStatus) { _, _ in
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
            Task { await viewModel.fetchProducts() }
        }
    }
}
