import SwiftUI

struct ChiefOfficerDashboardView: View {

    @StateObject private var factoryVM = FactoryViewModel()
    @StateObject private var productVM = ProductsViewModel()
    @StateObject private var restockVM = CreateRestockRequestViewModel()

    @State private var factorySearch = ""
    @State private var productSearch = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Factory")
                            .font(.headline)

                        TextField("Search factory…", text: $factorySearch)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: factorySearch) {
                                factoryVM.searchText = factorySearch
                                Task { await factoryVM.fetchFactories(page: 0) }
                            }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(factoryVM.factories) { factory in
                                    FactoryCard(
                                        factory: factory,
                                        isSelected: restockVM.selectedFactoryId
                                            == factory.id
                                    )
                                    .onTapGesture {
                                        restockVM.selectedFactoryId = factory.id
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Product")
                            .font(.headline)

                        TextField("Search product…", text: $productSearch)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: productSearch) {
                                productVM.searchText = productSearch
                                Task { await productVM.fetchProducts(page: 0) }
                            }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(productVM.products) { product in
                                    ProductCard(
                                        product: product,
                                        isSelected: restockVM.selectedProductId
                                            == product.id
                                    )
                                    .onTapGesture {
                                        restockVM.selectedProductId = product.id
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.headline)

                        TextField(
                            "Enter quantity",
                            text: $restockVM.qtyRequested
                        )
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    }

                    Button {
                        Task { await restockVM.createRestockRequest() }
                    } label: {
                        Text(
                            restockVM.isSubmitting
                                ? "Submitting…" : "Create Restock Request"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            restockVM.isValid
                                ? Color.blue : Color.gray.opacity(0.4)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!restockVM.isValid || restockVM.isSubmitting)

                    if let message = restockVM.errorMessage {
                        Text(message)
                            .foregroundColor(.red)
                    }
                    if let message = restockVM.successMessage {
                        Text(message)
                            .foregroundColor(.green)
                    }

                }
                .padding()
            }
            .navigationTitle("Create Restock Request")
        }
    }
}

struct ProductCard: View {
    let product: Product
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(product.name)
                .font(.headline)

            Text("₹\(product.price, specifier: "%.2f")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 150, height: 90)
        .background(
            isSelected ? Color.green.opacity(0.2) : Color.gray.opacity(0.1)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}

struct FactoryCard: View {
    let factory: Factory
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(factory.name)
                .font(.headline)

            let city = factory.city
            Text(city)
                .font(.caption)
                .foregroundColor(.secondary)

        }
        .padding()
        .frame(width: 150, height: 90)
        .background(
            isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}
