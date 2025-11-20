//import SwiftUI
//
//struct ProductRow: View {
//    let product: Product
//
//    var body: some View {
//        HStack(spacing: 12) {
//            AsyncImage(url: URL(string: product.image ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                        .frame(width: 60, height: 60)
//                case .success(let image):
//                    image.resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 60, height: 60)
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                case .failure:
//                    Image(systemName: "photo")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 60, height: 60)
//                        .foregroundColor(.gray)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(product.name)
//                    .font(.headline)
//                Text(product.categoryName)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                Text("₹\(product.price, specifier: "%.2f")")
//                    .font(.subheadline)
//                    .foregroundColor(.blue)
//            }
//        }
//        .padding(.vertical, 6)
//    }
//}
//
//struct ProductsListView: View {
//    @StateObject private var viewModel = ProductsViewModel()
//    @State private var showAddProduct = false
//    @State private var hasAppeared = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//
//            VStack(spacing: 10) {
//
//                HStack {
//                    Image(systemName: "magnifyingglass")
//                        .foregroundColor(.gray)
//                    TextField("Search products", text: $viewModel.searchText)
//                        .textFieldStyle(.plain)
//                        .disableAutocorrection(true)
//                        .autocapitalization(.none)
//
//                    if !viewModel.searchText.isEmpty {
//                        Button {
//                            viewModel.searchText = ""
//                        } label: {
//                            Image(systemName: "xmark.circle.fill")
//                                .foregroundColor(.gray)
//                        }
//                    }
//                }
//                .padding(10)
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//                .padding(.horizontal)
//
//                VStack(alignment: .leading, spacing: 10) {
//                    CategoryFilterRow(vm: viewModel)
//                    StatusFilterRow(vm: viewModel)
//                }
//                .padding(.vertical, 8)
//                .background(Color(.systemBackground))
//                .cornerRadius(12)
//                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
//                .padding(.horizontal)
//            }
//            .padding(.vertical, 10)
//            .background(Color(UIColor.systemBackground))
//            .overlay(Divider(), alignment: .bottom)
//            .zIndex(1)
//
//            Group {
//                if viewModel.isLoading {
//                    VStack(spacing: 12) {
//                        ProgressView()
//                        Text("Loading products...")
//                            .foregroundColor(.secondary)
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                } else if let error = viewModel.errorMessage {
//                    VStack(spacing: 12) {
//                        Image(systemName: "exclamationmark.triangle.fill")
//                            .foregroundColor(.orange)
//                            .font(.system(size: 30))
//                        Text(error)
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                        Button("Retry") {
//                            Task { await viewModel.fetchProducts() }
//                        }
//                        .buttonStyle(.borderedProminent)
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                } else if viewModel.products.isEmpty {
//                    VStack(spacing: 12) {
//                        Image(systemName: "shippingbox.fill")
//                            .foregroundColor(.secondary)
//                            .font(.system(size: 32))
//                        Text("No products found")
//                            .foregroundColor(.secondary)
//                        Button("Add Product") {
//                            showAddProduct = true
//                        }
//                        .buttonStyle(.bordered)
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                } else {
//                    List(viewModel.products) { product in
//                        NavigationLink {
//                            ProductDetailView(
//                                product: product,
//                                viewModel: viewModel
//                            )
//                        } label: {
//                            ProductRow(product: product)
//                                .padding(.vertical, 4)
//                        }
//                    }
//                    .listStyle(.insetGrouped)
//                }
//            }
//            .onChange(of: viewModel.searchText) { _, _ in
//                Task { await viewModel.fetchProducts() }
//            }
//            .onChange(of: viewModel.selectedCategoryId) { _, _ in
//                Task { await viewModel.fetchProducts() }
//            }
//            .onChange(of: viewModel.selectedStatus) { _, _ in
//                Task { await viewModel.fetchProducts() }
//            }
//        }
//        .navigationTitle("Products")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    showAddProduct = true
//                } label: {
//                    Image(systemName: "plus")
//                }
//            }
//        }
//        .sheet(isPresented: $showAddProduct) {
//            AddProductView(viewModel: viewModel)
//        }
//        .onAppear {
//            guard !hasAppeared else { return }
//            hasAppeared = true
//            Task { await viewModel.fetchProducts() }
//        }
//    }
//}
