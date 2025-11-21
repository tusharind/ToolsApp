import SwiftUI

@MainActor
final class CreateToolViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var selectedCategoryId: Int? = nil
    @Published var type: String = ""
    @Published var nameTouched = false

    var isExpensive: String = "NO"

    var isExpensiveBool: Bool {
        get { isExpensive == "YES" }
        set { isExpensive = newValue ? "YES" : "NO" }
    }

    @Published var threshold: Int = 0
    @Published var selectedImage: UIImage? = nil
    @Published var isLoading = false

    @Published var categories: [ToolCategory] = []

    @Published var alertMessage: AlertMessage?

    struct AlertMessage: Identifiable {
        let id = UUID()
        let title: String
        let body: String
    }

    init() {
        fetchCategories()
    }

    func fetchCategories() {
        Task {
            do {
                let request = APIRequest(
                    path: "/tools/tool-categories?page=0&size=50&sortBy=name",
                    method: .GET,
                    parameters: nil,
                    headers: nil
                )

                let response: PaginatedResponse<ToolCategory> =
                    try await APIClient.shared.send(
                        request,
                        responseType: PaginatedResponse<ToolCategory>.self
                    )

                self.categories = response.data.content

            }
        }
    }

    func createTool() async {
        guard
            let categoryId = selectedCategoryId,
            let image = selectedImage,
            !name.isEmpty,
            !type.isEmpty
        else {
            alertMessage = AlertMessage(
                title: "Error",
                body: "All fields are required"
            )
            return
        }

        isLoading = true

        var formBuilder = MultipartFormDataBuilder()
        formBuilder.addField(name: "name", value: name)
        formBuilder.addField(name: "categoryId", value: "\(categoryId)")
        formBuilder.addField(name: "type", value: type)
        formBuilder.addField(name: "isExpensive", value: "\(isExpensive)")
        formBuilder.addField(name: "threshold", value: "\(threshold)")
        formBuilder.addImageField(name: "image", image: image)
        let (bodyData, boundary) = formBuilder.finalize()

        let endpoint = APIEndpoint(
            path:
                "https://herschel-hyperneurotic-hilma.ngrok-free.dev/tools/create",
            method: .POST,
            body: bodyData,
            requiresAuth: true,
            contentType: "multipart/form-data; boundary=\(boundary)"
        )

        do {
            let response: ToolCreationResponse = try await APIService.shared
                .request(
                    endpoint: endpoint,
                    responseType: ToolCreationResponse.self
                )

            if response.success {
                alertMessage = AlertMessage(
                    title: "Success",
                    body: response.message
                )
            } else {
                alertMessage = AlertMessage(
                    title: "Error",
                    body: response.message
                )
            }
        } catch {
            alertMessage = AlertMessage(
                title: "Error",
                body: error.localizedDescription
            )
        }

        isLoading = false
    }
}

extension CreateToolViewModel {
    var nameError: String? {
        guard nameTouched else { return nil }
        return name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Name is required"
            : nil
    }
}
