import SwiftUI

struct CreateToolView: View {
    @StateObject private var viewModel = CreateToolViewModel()
    @State private var showImagePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Name")
                            .font(.headline)
                        TextField("Enter tool name", text: $viewModel.name)
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .autocapitalization(.words)
                            .onChange(of: viewModel.name) { _, _ in
                                viewModel.nameTouched = true
                            }

                        if let error = viewModel.nameError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Category")
                            .font(.headline)
                        Picker(
                            "Select a category",
                            selection: $viewModel.selectedCategoryId
                        ) {
                            Text("Select a category").tag(Int?.none)
                            ForEach(viewModel.categories) { cat in
                                Text(cat.name).tag(Int?(cat.id))
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Type")
                            .font(.headline)
                        Picker("Select type", selection: $viewModel.type) {
                            ForEach(ToolType.allCases) { type in
                                Text(type.rawValue.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Toggle("Is Expensive", isOn: $viewModel.isExpensiveBool)
                        .padding(.top)

                    Stepper(
                        "Threshold: \(viewModel.threshold)",
                        value: $viewModel.threshold,
                        in: 0...100
                    )
                    .padding(.top)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Image")
                            .font(.headline)
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                        }
                        Button(action: { showImagePicker = true }) {
                            Text("Select Image")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top)

                    Button(action: {
                        Task { await viewModel.createTool() }
                    }) {
                        Text("Create Tool")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                isFormValid
                                    && viewModel.selectedCategoryId != nil
                                    && viewModel.selectedImage != nil
                                    ? Color.accentColor
                                    : Color.gray.opacity(0.5)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(
                        viewModel.isLoading
                            || !isFormValid
                            || viewModel.selectedCategoryId == nil
                            || viewModel.selectedImage == nil
                    )
                    .padding(.vertical)
                }
                .padding()
            }
            .navigationTitle("Create Tool")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $viewModel.selectedImage)
            }
            .alert(item: $viewModel.alertMessage) { message in
                Alert(
                    title: Text(message.title),
                    message: Text(message.body),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }


    private var isFormValid: Bool {
        viewModel.nameError == nil
    }
}
