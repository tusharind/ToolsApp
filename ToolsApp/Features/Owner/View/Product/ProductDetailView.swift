import SwiftUI

struct ProductDetailView: View {
    @ObservedObject var viewModel: ProductsViewModel
    @State private var product: Product
    @State private var isShowingEditSheet = false
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) private var dismiss

    init(product: Product, viewModel: ProductsViewModel) {
        _product = State(initialValue: product)
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                ZStack(alignment: .bottomTrailing) {
                    productImageView

                    Button {
                        if viewModel.selectedImage == nil {
                            viewModel.isShowingImagePicker = true
                        } else {
                            Task {
                                await viewModel.uploadImage(for: product.id)
                            }
                        }
                    } label: {
                        Image(
                            systemName: viewModel.selectedImage == nil
                                ? "pencil" : "square.and.arrow.up"
                        )
                        .font(.system(size: 17, weight: .semibold))
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                    }
                    .padding(8)
                }

                if let message = viewModel.uploadMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 18) {
                    productBasicInfo
                    productDescription
                    productAdditionalInfo
                }

                VStack(spacing: 12) {
                    editButton
                    deleteButton
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.isShowingImagePicker) {
            ImagePicker(
                selectedImage: $viewModel.selectedImage,
                sourceType: .photoLibrary
            )
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditProductView(product: product, viewModel: viewModel) {
                updatedProduct in
                self.product = updatedProduct
                isShowingEditSheet = false
            }
        }
    }

    private var productImageView: some View {
        ZStack {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let urlString = product.image,
                let url = URL(string: urlString)
            {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(width: 160, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.gray.opacity(0.08))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 38))
                    .foregroundColor(.gray.opacity(0.5))
            )
            .frame(width: 160, height: 160)
    }

    private var productBasicInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.name)
                .font(.title3.weight(.semibold))

            Text(product.categoryName)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text("₹\(product.price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.blue)

                Spacer()

                Text("\(product.rewardPts) pts")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.orange)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.orange.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private var productDescription: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Description")
                .font(.headline)

            Text(product.prodDescription)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private var productAdditionalInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Additional Info")
                .font(.headline)

            infoRow(
                "Status:",
                value: product.status.capitalized,
                color: product.status.lowercased() == "active" ? .green : .red
            )

            infoRow("Created At:", value: product.createdAt.formattedDate())
            infoRow("Updated At:", value: product.updatedAt.formattedDate())
            infoRow("Category ID:", value: "\(product.categoryId)")
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private func infoRow(_ title: String, value: String, color: Color? = nil)
        -> some View
    {
        HStack {
            Text(title).bold()
            Text(value)
                .foregroundColor(color ?? .secondary)
        }
    }

    private var editButton: some View {
        Button {
            isShowingEditSheet = true
        } label: {
            HStack {
                Image(systemName: "pencil")
                Text("Edit Product").bold()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }

    private var deleteButton: some View {
        let isInactive = product.status.lowercased() == "inactive"

        return Button(role: .destructive) {
            showDeleteAlert = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Product").bold()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isInactive ? Color.gray : Color.red)
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(isInactive ? 0.55 : 1)
        }
        .disabled(isInactive)
        .alert("Delete Product?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteProduct(id: product.id)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this product?")
        }
    }
}
