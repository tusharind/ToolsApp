import SwiftUI

struct CreateToolView: View {
    @StateObject private var viewModel = CreateToolViewModel()

    @State private var showImagePicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Tool Info") {
                    TextField("Name", text: $viewModel.name)

                    Picker("Category", selection: $viewModel.selectedCategoryId)
                    {
                        Text("Select a category").tag(Int?.none)
                        ForEach(viewModel.categories) { cat in
                            Text(cat.name).tag(Int?(cat.id))
                        }
                    }

                    TextField("Type", text: $viewModel.type)

                    Toggle("Is Expensive", isOn: $viewModel.isExpensiveBool)

                    Stepper(
                        "Threshold: \(viewModel.threshold)",
                        value: $viewModel.threshold,
                        in: 0...100
                    )
                }

                Section("Image") {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
                    }

                    Button("Select Image") {
                        showImagePicker = true
                    }
                }

                Section {
                    Button("Create Tool") {
                        Task {
                            await viewModel.createTool()
                        }
                    }
                    .disabled(
                        viewModel.isLoading
                            || viewModel.selectedCategoryId == nil
                            || viewModel.selectedImage == nil
                    )
                }
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
}
