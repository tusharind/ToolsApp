import PhotosUI
import SwiftUI

struct ProductDetailView: View {
    @ObservedObject var viewModel: ProductsViewModel
    @State private var product: Product

    @State private var showAlert: ActiveAlert?
    @State private var isProcessing = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var uploadSuccess = false

    init(product: Product, viewModel: ProductsViewModel) {
        _product = State(initialValue: product)
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                productImageView
                imageUploadButton
                productBasicInfo
                productDescription
                productAdditionalInfo
                deactivateButton
            }
            .padding()
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $showAlert) { alert in
            switch alert {
            case .confirmDeactivate:
                return Alert(
                    title: Text("Deactivate Product?"),
                    message: Text(
                        "This action will mark the product as inactive."
                    ),
                    primaryButton: .destructive(Text("Deactivate")) {
                        //   Task { await deactivateProduct() }
                    },
                    secondaryButton: .cancel()
                )
            case .success:
                return Alert(
                    title: Text("Product deactivated successfully!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// MARK: - Subviews
extension ProductDetailView {
    fileprivate var productImageView: some View {
        AsyncImage(url: URL(string: product.image ?? "")) { phase in
            switch phase {
            case .empty:
                ProgressView().frame(maxWidth: .infinity, minHeight: 200)
            case .success(let image):
                image.resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }

    fileprivate var imageUploadButton: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            HStack {
                if isProcessing { ProgressView().padding(.trailing, 8) }
                Text("Upload Image").bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isProcessing)
        .onChange(of: selectedItem) { newItem in
            guard let item = newItem else { return }
            Task { await uploadSelectedImage(item) }
        }
        .alert("Image uploaded successfully!", isPresented: $uploadSuccess) {
            Button("OK", role: .cancel) {}
        }
    }

    fileprivate var productBasicInfo: some View {
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

    fileprivate var productDescription: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Description").font(.headline)
            Text(product.prodDescription).font(.body).foregroundColor(
                .secondary
            )
        }
        .cardStyle()
    }

    fileprivate var productAdditionalInfo: some View {
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

    fileprivate var deactivateButton: some View {
        Group {
            if product.status.lowercased() == "active" {
                Button {
                    showAlert = .confirmDeactivate
                } label: {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: .white)
                                )
                                .padding(.trailing, 8)
                        }
                        Text("Deactivate Product").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isProcessing)
            }
        }
    }
}

// MARK: - Functions
extension ProductDetailView {

    private func uploadSelectedImage(_ item: PhotosPickerItem) async {
        isProcessing = true
        defer { isProcessing = false }

        guard let data = try? await item.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
        else {
            return
        }

        do {
            // Use your builder to correctly format multipart
            var builder = MultipartFormDataBuilder()
            builder.addImageField(
                name: "imageFile",
                image: uiImage,
                filename: "product.jpg"
            )
            let (body, boundary) = builder.finalize()

            let request = APIRequest(
                path: "/owner/uploadImage/\(product.id)",
                method: .POST,
                parameters: nil,
                headers: nil,
                body: body,
                contentType: "multipart/form-data; boundary=\(boundary)"
            )

            // Send request
            let response = try await APIClient.shared.send(
                request,
                responseType: APIResponse<Product>.self
            )

            if let updatedProduct = response.data {
                product = updatedProduct
                uploadSuccess = true
            } else {
                print("Upload failed:", response.message)
            }

        } catch {
            print("Upload failed:", error.localizedDescription)
        }
    }

}

// MARK: - Alert Enum
enum ActiveAlert: Identifiable {
    case confirmDeactivate, success
    var id: Int { hashValue }
}

// MARK: - Card Style Modifier
extension View {
    func cardStyle() -> some View {
        self.padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
    }
}

struct MultipartFormDataBuilder {
    private let boundary = UUID().uuidString
    private var body = Data()

    mutating func addField(name: String, value: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    mutating func addImageField(
        name: String,
        image: UIImage,
        filename: String = "image.jpg"
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        body.append("--\(boundary)\r\n")
        body.append(
            "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n"
        )
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
    }

    mutating func finalize() -> (data: Data, boundary: String) {
        body.append("--\(boundary)--\r\n")
        return (body, boundary)
    }
}
