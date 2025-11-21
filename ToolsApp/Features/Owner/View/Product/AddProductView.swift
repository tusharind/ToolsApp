import SwiftUI

struct AddProductView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProductsViewModel

    var body: some View {
        NavigationView {
            Form {
                Section("Product Details") {
                    VStack(alignment: .leading) {
                        TextField("Name", text: $viewModel.name)
                            .autocapitalization(.words)
                            .onChange(of: viewModel.name) {
                                oldValue,
                                newValue in viewModel.nameTouched = true
                            }

                        if viewModel.nameTouched,
                            let error = viewModel.nameError
                        {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }

                    VStack(alignment: .leading) {
                        TextField("Description", text: $viewModel.description)
                            .autocapitalization(.sentences)
                            .onChange(of: viewModel.description) {
                                oldValue,
                                newValue in viewModel.descriptionTouched = true
                            }

                        if viewModel.descriptionTouched,
                            let error = viewModel.descriptionError
                        {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }

                Section("Pricing") {
                    VStack(alignment: .leading) {
                        TextField("Price (₹)", text: $viewModel.price)
                            .keyboardType(.decimalPad)
                            .onChange(of: viewModel.price) {
                                oldValue,
                                newValue in viewModel.priceTouched = true
                            }

                        if viewModel.priceTouched,
                            let error = viewModel.priceError
                        {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }

                    VStack(alignment: .leading) {
                        TextField("Reward Points", text: $viewModel.rewardPts)
                            .keyboardType(.numberPad)
                            .onChange(of: viewModel.rewardPts) {
                                oldValue,
                                newValue in viewModel.rewardTouched = true
                            }

                        if viewModel.rewardTouched,
                            let error = viewModel.rewardError
                        {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                Section("Category") {
                    VStack(spacing: 0) {
                        TextField(
                            "Search Category",
                            text: $viewModel.categorySearchText
                        )
                        .onChange(of: viewModel.categorySearchText) { _, _ in
                            Task { await viewModel.searchCategories() }
                        }
                        .textFieldStyle(.roundedBorder)
                        .disableAutocorrection(true)

                        if viewModel.isCategoryLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        if !viewModel.categories.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.categories) { category in
                                        Button(action: {
                                            viewModel.selectedCategoryId =
                                                category.id
                                            viewModel.selectedCategoryName =
                                                category.categoryName
                                            viewModel.categorySearchText =
                                                category.categoryName
                                            viewModel.categoryTouched = true
                                            hideKeyboard()
                                        }) {
                                            Text(category.categoryName)
                                                .padding()
                                                .frame(
                                                    maxWidth: .infinity,
                                                    alignment: .leading
                                                )
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

                        if viewModel.categoryTouched,
                            let error = viewModel.categoryError
                        {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }

                if !viewModel.alertMessage.isEmpty {
                    Text(viewModel.alertMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            .disabled(viewModel.isSubmitting)
            .navigationTitle("Add Product")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task { await viewModel.createProduct() }
                    }
                    .disabled(!viewModel.isFormValid)
                }
            }
            .alert("Result", isPresented: $viewModel.showAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

#if canImport(UIKit)
    extension View {
        func hideKeyboard() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
#endif
