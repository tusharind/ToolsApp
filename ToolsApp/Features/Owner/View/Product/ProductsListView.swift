import SwiftUI

struct ProductsListView: View {
    @StateObject private var viewModel = ProductsViewModel()
    @State private var showAddProduct = false
    @State private var hasAppeared = false

    var body: some View {
            VStack(spacing: 0) {
                
                // MARK: - Search & Filter Bar
                VStack(spacing: 10) {
                    
                    // Search Bar
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
                    
                    // Filter Row
                    HStack(spacing: 12) {
                        Picker("Category", selection: $viewModel.selectedCategoryId) {
                            Text("All Categories").tag(nil as Int?)
                            Text("Farming").tag(1 as Int?)
                            Text("Electronics").tag(2 as Int?)
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        
                        Picker("Status", selection: $viewModel.selectedStatus) {
                            Text("All Status").tag(nil as String?)
                            Text("Active").tag("ACTIVE")
                            Text("Inactive").tag("INACTIVE")
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
                .overlay(Divider(), alignment: .bottom)
                .zIndex(1)
                
                // MARK: - List / States
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
                                ProductDetailView(product: product, viewModel: viewModel)
                            } label: {
                                ProductRow(product: product)
                                    .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .onChange(of: viewModel.searchText) { newValue,oldValue in
                    Task { await viewModel.fetchProducts() }
                }
                .onChange(of: viewModel.selectedCategoryId) { newValue,oldValue in
                    Task { await viewModel.fetchProducts() }
                }
                .onChange(of: viewModel.selectedStatus) { newValue,oldValue in
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

