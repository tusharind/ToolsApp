import SwiftUI

struct AddProductView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProductsViewModel

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var rewardPts: String = ""
    @State private var categoryId: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section("Product Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }

                Section("Pricing") {
                    TextField("Price (₹)", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Reward Points", text: $rewardPts)
                        .keyboardType(.numberPad)
                }

                Section("Category") {
                    TextField("Category ID", text: $categoryId)
                        .keyboardType(.numberPad)
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            .disabled(isSubmitting)
            .navigationTitle("Add Product")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { Task { await submitProduct() } }
                        .disabled(!isFormValid)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !name.isEmpty && !description.isEmpty
            && Double(price) != nil && Int(rewardPts) != nil
            && Int(categoryId) != nil
    }

    private func submitProduct() async {
        guard let priceValue = Double(price),
            let rewardValue = Int(rewardPts),
            let catId = Int(categoryId)
        else { return }

        isSubmitting = true
        errorMessage = nil

        let newProduct = CreateProductRequest(
            name: name,
            prodDescription: description,
            price: priceValue,
            rewardPts: rewardValue,
            categoryId: catId
        )

        let success = await viewModel.addProduct(newProduct)
        isSubmitting = false

        if success {
            dismiss()
        } else {
            errorMessage = viewModel.errorMessage ?? "Something went wrong."
        }
    }
}
