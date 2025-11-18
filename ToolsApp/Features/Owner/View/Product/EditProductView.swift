import SwiftUI

struct EditProductView: View {
    @ObservedObject var viewModel: ProductsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var price: String
    @State private var rewardPts: String
    @State private var selectedCategoryId: Int
    @State private var selectedStatus: String
    @State private var selectedImage: UIImage?

    @State private var isShowingImagePicker = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let product: Product
    private let onSave: (Product) -> Void

    private let statuses = ["ACTIVE", "INACTIVE"]

    init(product: Product, viewModel: ProductsViewModel, onSave: @escaping (Product) -> Void) {
        self.product = product
        self.viewModel = viewModel
        self.onSave = onSave

        _name = State(initialValue: product.name)
        _description = State(initialValue: product.prodDescription)
        _price = State(initialValue: "\(product.price)")
        _rewardPts = State(initialValue: "\(product.rewardPts)")
        _selectedCategoryId = State(initialValue: product.categoryId)
        _selectedStatus = State(initialValue: product.status.uppercased())
        _selectedImage = State(initialValue: nil)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    imageSection
                    inputFields
                    categoryPicker
                    statusPicker
                    saveButton

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                .padding()
            }
            .navigationTitle("Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
        }
    }
}

// MARK: - Subviews
extension EditProductView {
    private var imageSection: some View {
        VStack(spacing: 12) {
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else if let url = URL(string: product.image ?? "") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty: ProgressView().frame(width: 180, height: 180)
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        case .failure: placeholderImage
                        @unknown default: placeholderImage
                        }
                    }
                } else {
                    placeholderImage
                }
            }
            .onTapGesture { isShowingImagePicker = true }

            Button(selectedImage == nil ? "Edit Image" : "Upload Image") {
                if selectedImage != nil {
                    Task { await uploadImage() }
                } else {
                    isShowingImagePicker = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .disabled(isSaving)
        }
    }

    private var placeholderImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 180, height: 180)
            Image(systemName: "photo")
                .font(.system(size: 48))
                .foregroundColor(.gray)
        }
    }

    private var inputFields: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
            TextField("Description", text: $description)
                .textFieldStyle(.roundedBorder)
            TextField("Price", text: $price)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
            TextField("Reward Points", text: $rewardPts)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading) {
            Text("Category").bold()
            Picker("Category", selection: $selectedCategoryId) {
                ForEach(viewModel.categories) { category in
                    Text(category.categoryName).tag(category.id)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var statusPicker: some View {
        VStack(alignment: .leading) {
            Text("Status").bold()
            Picker("Status", selection: $selectedStatus) {
                ForEach(statuses, id: \.self) { status in
                    Text(status.capitalized).tag(status)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var saveButton: some View {
        Button {
            Task { await saveProduct() }
        } label: {
            HStack {
                if isSaving { ProgressView() }
                Text("Save").bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isSaving)
    }
}

// MARK: - Actions
extension EditProductView {
    private func saveProduct() async {
        guard let priceValue = Double(price),
              let rewardValue = Int(rewardPts)
        else {
            errorMessage = "Enter valid price and reward points."
            return
        }

        let request = UpdateProductRequest(
            name: name,
            prodDescription: description,
            price: priceValue,
            rewardPts: rewardValue,
            categoryId: selectedCategoryId
        )

        isSaving = true
        defer { isSaving = false }

        // Pass the product.id separately to the viewModel
        let success = await viewModel.editProduct(id: product.id, request)
        if success {
            var updatedProduct = product
            updatedProduct.name = name
            updatedProduct.prodDescription = description
            updatedProduct.price = priceValue
            updatedProduct.rewardPts = rewardValue
            updatedProduct.categoryId = selectedCategoryId
            updatedProduct.status = selectedStatus
            if let _ = selectedImage {
                updatedProduct.image = product.image // optional: refresh after upload
            }
            onSave(updatedProduct)
            dismiss()
        } else {
            errorMessage = viewModel.errorMessage ?? "Failed to update product."
        }
    }

    private func uploadImage() async {
        guard let image = selectedImage else { return }
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        await viewModel.uploadImage(for: product.id)
    }
}

