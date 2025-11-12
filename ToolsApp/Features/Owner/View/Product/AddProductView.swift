import SwiftUI

struct AddProductView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProductsViewModel

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var rewardPts: String = ""
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
                    VStack(spacing: 0) {
                        TextField("Search Category", text: $viewModel.categorySearchText)
                            .onChange(of: viewModel.categorySearchText) { newValue,oldValue in
                                Task { await viewModel.searchCategories() }
                            }

                        if viewModel.isCategoryLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        if !viewModel.categories.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.categories) { category in
                                        Button(action: {
                                            viewModel.selectedCategoryId = category.id
                                            viewModel.selectedCategoryName = category.categoryName
                                            viewModel.categorySearchText = category.categoryName
                                            hideKeyboard()
                                        }) {
                                            Text(category.categoryName)
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        Divider()
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
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
            && viewModel.selectedCategoryId != nil
    }

    private func submitProduct() async {
        guard let priceValue = Double(price),
              let rewardValue = Int(rewardPts),
              let catId = viewModel.selectedCategoryId
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

// Helper to dismiss keyboard
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

