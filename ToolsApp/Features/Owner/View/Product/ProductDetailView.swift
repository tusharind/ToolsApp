import SwiftUI

struct ProductDetailView: View {
    @ObservedObject var viewModel: ProductsViewModel
    @State private var product: Product

    init(product: Product, viewModel: ProductsViewModel) {
        _product = State(initialValue: product)
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                productImageView
                uploadButton
                productBasicInfo
                productDescription
                productAdditionalInfo
            }
            .padding()
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.isShowingImagePicker) {
            ImagePicker(
                selectedImage: $viewModel.selectedImage,
                sourceType: .photoLibrary
            )
        }
    }

    private var productImageView: some View {
        Group {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
            } else if let urlString = product.image,
                let url = URL(string: urlString)
            {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView().frame(width: 160, height: 160)
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .foregroundColor(.gray)
                    @unknown default: EmptyView()
                    }
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 160, height: 160)
                    Image(systemName: "photo.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }
            }
        }
        .onTapGesture { viewModel.isShowingImagePicker = true }
    }

    private var uploadButton: some View {
        Button {
            if viewModel.selectedImage == nil {

                viewModel.isShowingImagePicker = true
            } else {

                Task { await viewModel.uploadImage(for: product.id) }

            }
        } label: {
            HStack {
                if viewModel.isUploading { ProgressView() }
                Text(
                    viewModel.selectedImage == nil
                        ? "Select Image" : "Upload Image"
                ).bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(viewModel.isUploading)
        .overlay(
            Group {
                if let message = viewModel.uploadMessage {
                    Text(message)
                        .foregroundColor(.secondary)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            },
            alignment: .bottom
        )
    }

    private var productBasicInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.name).font(.title).bold()
            Text(product.categoryName).font(.subheadline).foregroundColor(
                .secondary
            )
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
        .cardStyle()
    }

    private var productDescription: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Description").font(.headline)
            Text(product.prodDescription)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .cardStyle()
    }

    private var productAdditionalInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Additional Info").font(.headline)
            HStack {
                Text("Status:").bold()
                Text(product.status.capitalized).foregroundColor(
                    product.status.lowercased() == "active" ? .green : .red
                )
            }
            HStack {
                Text("Created At:").bold()
                Text(product.createdAt.formattedDate()).foregroundColor(
                    .secondary
                )
            }
            HStack {
                Text("Updated At:").bold()
                Text(product.updatedAt.formattedDate()).foregroundColor(
                    .secondary
                )
            }
            HStack {
                Text("Category ID:").bold()
                Text("\(product.categoryId)").foregroundColor(.secondary)
            }
        }
        .cardStyle()
    }
}
