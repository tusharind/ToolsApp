import SwiftUI

@MainActor
final class CentralOfficerViewModel: ObservableObject {

    @Published var offices: [CentralOffice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var searchText: String = "" {
        didSet {
            validateSearchText()
        }
    }

    @Published var selectedRole: String? = nil

    private let client = APIClient.shared

    private func validateSearchText() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let cleaned = trimmed.replacingOccurrences(
            of: #"[^A-Za-z0-9\s@._-]"#,
            with: "",
            options: .regularExpression
        )
        
        if cleaned != searchText {
            searchText = cleaned
        }
    }

    private func sanitizedInput(_ input: String) -> String {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func fetchOffices() async {
        isLoading = true
        errorMessage = nil

        let request = APIRequest(
            path: "/owner/central-officer",
            method: .GET,
            parameters: nil,
            headers: nil,
            body: nil
        )

        do {
            let response: APIResponse<[CentralOffice]> = try await client.send(
                request,
                responseType: APIResponse<[CentralOffice]>.self
            )

            if response.success, let officesData = response.data {
                self.offices = officesData
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func canAddOfficer(email: String) -> Bool {
        !offices.flatMap { $0.officers }.contains {
            $0.email.lowercased() == email.lowercased()
        }
    }

    func addOfficer(
        to officeId: Int,
        name: String,
        email: String,
        phone: String?
    ) async {
        let sanitizedName = sanitizedInput(name)
        let sanitizedEmail = sanitizedInput(email)

        
        guard !sanitizedName.isEmpty else {
            self.errorMessage = "Officer name cannot be empty or only spaces."
            return
        }

        guard !sanitizedEmail.isEmpty else {
            self.errorMessage = "Officer email cannot be empty or only spaces."
            return
        }

        guard canAddOfficer(email: sanitizedEmail) else {
            self.errorMessage = "This officer is already assigned to an office"
            return
        }

        isLoading = true
        errorMessage = nil

        let body = AddOfficerRequest(
            centralOfficeId: officeId,
            centralOfficerName: sanitizedName,
            centralOfficerEmail: sanitizedEmail,
            phone: phone
        )

        let request = APIRequest(
            path: "/owner/add-central-officer",
            method: .POST,
            parameters: nil,
            headers: nil,
            body: body
        )

        do {
            let response: APIResponse<CentralOfficer> = try await client.send(
                request,
                responseType: APIResponse<CentralOfficer>.self
            )

            if response.success {
                await fetchOffices()
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func filteredOfficers(for office: CentralOffice) -> [CentralOfficer] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return office.officers.filter { officer in
            (trimmedSearch.isEmpty
                || officer.username.localizedCaseInsensitiveContains(trimmedSearch))
                && (selectedRole == nil || officer.role == selectedRole)
        }
    }
}

