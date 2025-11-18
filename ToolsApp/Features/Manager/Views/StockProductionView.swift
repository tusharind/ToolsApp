import SwiftUI

struct StockProductionView: View {
    @StateObject private var viewModel = StockProductionViewModel()

    var body: some View {
        NavigationStack {
            VStack {

                TextField("Search products...", text: $viewModel.searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .onChange(of: viewModel.searchText) { newValue, oldValue in
                        Task { await viewModel.fetchProducts() }
                    }

                if viewModel.isLoading && viewModel.products.isEmpty {
                    Spacer()
                    ProgressView("Loading products…")
                    Spacer()
                } else if viewModel.products.isEmpty {
                    Spacer()
                    Text("No products found")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.products, id: \.id) { product in
                                ProductRowSection(
                                    product: product,
                                    isSelected: viewModel.selectedProduct?.id
                                        == product.id
                                )
                                .onTapGesture {
                                    viewModel.selectedProduct = product
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }

                if viewModel.selectedProduct != nil {
                    VStack(spacing: 10) {
                        TextField("Enter quantity", text: $viewModel.quantity)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)

                        Button(action: {
                            Task { await viewModel.addStock() }
                        }) {
                            Text(
                                viewModel.isLoading
                                    ? "Processing..." : "Add Stock"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }

                if let success = viewModel.successMessage {
                    Text(success)
                        .foregroundColor(.green)
                        .padding(.top, 5)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
            }
            .navigationTitle("Add Stock")
        }
    }
}


