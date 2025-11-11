import SwiftUI

@MainActor
final class CentralOfficerViewModel: ObservableObject {

    @Published var offices: [CentralOffice] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var searchText: String = ""
    @Published var selectedRole: String? = nil
    
    private let client = APIClient.shared
    
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
        !offices.flatMap { $0.officers }.contains { $0.email.lowercased() == email.lowercased() }
    }
    
    func addOfficer(to officeId: Int, name: String, email: String, phone: String?) async {
        guard canAddOfficer(email: email) else {
            self.errorMessage = "This officer is already assigned to an office"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let body = AddOfficerRequest(
            centralOfficeId: officeId,
            centralOfficerName: name,
            centralOfficerEmail: email,
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
        office.officers.filter { officer in
            (searchText.isEmpty || officer.username.localizedCaseInsensitiveContains(searchText)) &&
            (selectedRole == nil || officer.role == selectedRole)
        }
    }
}

