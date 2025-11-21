import Combine
import SwiftUI

@MainActor
final class CentralOfficerViewModel: ObservableObject {

    @Published var offices: [CentralOffice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var selectedRole: String? = nil

    @Published private(set) var filteredOfficesList: [CentralOffice] = []

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var isSubmitting: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    private let client = APIClient.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
 
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.applyLocalFilter()
            }
            .store(in: &cancellables)
    }

    private func sanitizedInput(_ input: String) -> String {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nameError: String? {
        let trimmed = sanitizedInput(name)
        let regex = "^[A-Za-z ]+$"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        if trimmed.isEmpty { return "Name cannot be empty" }
        if !test.evaluate(with: trimmed) { return "Name can contain letters and spaces only" }
        return nil
    }

    var emailError: String? {
        let trimmed = sanitizedInput(email)
        let regex = #"^\S+@\S+\.\S+$"#
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        if trimmed.isEmpty { return "Email cannot be empty" }
        if !test.evaluate(with: trimmed) { return "Invalid email format" }
        if !canAddOfficer(email: trimmed) { return "This officer already exists" }
        return nil
    }

    var phoneError: String? {
        let trimmed = sanitizedInput(phone)
        if trimmed.isEmpty { return nil } // optional
        let regex = #"^\d{10}$"#
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        if !test.evaluate(with: trimmed) { return "Phone must be 10 digits" }
        return nil
    }

    var isFormValid: Bool {
        nameError == nil && emailError == nil && phoneError == nil
    }

    func canAddOfficer(email: String) -> Bool {
        !offices.flatMap { $0.officers }.contains {
            $0.email.lowercased() == email.lowercased()
        }
    }

    func addOfficer(to officeId: Int) async -> Bool {
 
        let sanitizedName = sanitizedInput(name)
        let sanitizedEmail = sanitizedInput(email)
        let sanitizedPhone = sanitizedInput(phone).isEmpty ? nil : sanitizedInput(phone)

 
        guard isFormValid else { return false }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let body = AddOfficerRequest(
            centralOfficeId: officeId,
            centralOfficerName: sanitizedName,
            centralOfficerEmail: sanitizedEmail,
            phone: sanitizedPhone
        )

        let request = APIRequest(
            path: "/owner/add-central-officer",
            method: .POST,
            body: body
        )

        do {
            let response: APIResponse<CentralOfficer> = try await client.send(
                request,
                responseType: APIResponse<CentralOfficer>.self
            )

            if response.success {
                await fetchOffices()
                alertMessage = "Officer added successfully!"
                showAlert = true
                // Reset form
                name = ""
                email = ""
                phone = ""
                return true
            } else {
                alertMessage = response.message
                showAlert = true
                return false
            }
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
            return false
        }
    }

    func deleteOfficer(officerId: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let request = APIRequest(
            path: "/owner/central-office/central-officer/\(officerId)",
            method: .DELETE
        )

        do {
            let response: APIResponse<CentralOfficer?> = try await client.send(
                request,
                responseType: APIResponse<CentralOfficer?>.self
            )
            if response.success { await fetchOffices() }
            else { errorMessage = response.message }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchOffices(debounceDelay: Double = 0.3) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))

        let request = APIRequest(path: "/owner/central-officer", method: .GET)

        do {
            let response: APIResponse<[CentralOffice]> = try await client.send(
                request,
                responseType: APIResponse<[CentralOffice]>.self
            )
            if response.success, let officesData = response.data {
                self.offices = officesData
                applyLocalFilter()
            } else {
                self.errorMessage = response.message
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    private func applyLocalFilter() {
        let trimmedSearch = sanitizedInput(searchText)
        filteredOfficesList = offices.map { office in
            var filtered = office
            filtered.officers = office.officers.filter { officer in
                (trimmedSearch.isEmpty
                    || officer.username.localizedCaseInsensitiveContains(trimmedSearch))
                    && (selectedRole == nil || officer.role == selectedRole)
            }
            return filtered
        }
    }

    func filteredOfficers(for office: CentralOffice) -> [CentralOfficer] {
        let trimmedSearch = sanitizedInput(searchText)
        return office.officers.filter { officer in
            (trimmedSearch.isEmpty
                || officer.username.localizedCaseInsensitiveContains(trimmedSearch))
                && (selectedRole == nil || officer.role == selectedRole)
        }
    }

    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "inactive": return .red
        case "pending": return .orange
        default: return .blue
        }
    }
}

