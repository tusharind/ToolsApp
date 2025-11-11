import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @ObservedObject var viewModel: ProductsViewModel
    @State private var showAlert = false
    @State private var isProcessing = false
    @State private var showSuccessMessage = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                AsyncImage(url: URL(string: product.image ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.title)
                        .bold()
                    Text(product.categoryName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Text("₹\(product.price, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundColor(.blue)
                        Spacer()
                        Text("\(product.rewardPts) pts")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(6)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(
                        Color(UIColor.secondarySystemBackground)
                    )
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.headline)
                    Text(product.prodDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(
                        Color(UIColor.secondarySystemBackground)
                    )
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Info")
                        .font(.headline)

                    HStack {
                        Text("Status:")
                            .bold()
                        Text(product.status.capitalized)
                            .foregroundColor(
                                product.status.lowercased() == "active"
                                    ? .green : .red
                            )
                    }

                    HStack {
                        Text("Created At:")
                            .bold()
                        Text(product.createdAt.formattedDate())
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Updated At:")
                            .bold()
                        Text(product.updatedAt.formattedDate())
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Category ID:")
                            .bold()
                        Text("\(product.categoryId)")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(
                        Color(UIColor.secondarySystemBackground)
                    )
                )

                if product.status.lowercased() == "active" {
                    Button {
                        showAlert = true
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(tint: .white)
                                    )
                                    .padding(.trailing, 8)
                            }
                            Text("Deactivate Product")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.top)
                    .alert(
                        "Are you sure you want to deactivate this product?",
                        isPresented: $showAlert
                    ) {
                        Button("Cancel", role: .cancel) {}
                        Button("Deactivate", role: .destructive) {
                            Task {
                                isProcessing = true
                                let success = await viewModel.deactivateProduct(
                                    id: product.id
                                )
                                isProcessing = false
                                if success {
                                    showSuccessMessage = true
                                }
                            }
                        }
                    } message: {
                        Text("This action will mark the product as inactive.")
                    }
                    .alert(
                        "Product deactivated successfully!",
                        isPresented: $showSuccessMessage
                    ) {
                        Button("OK", role: .cancel) {}
                    }
                }

            }
            .padding()
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
