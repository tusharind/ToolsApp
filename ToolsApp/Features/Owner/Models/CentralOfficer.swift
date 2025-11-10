import Foundation

struct CentralOfficer: Identifiable, Codable {
    let userId: Int
    let username: String
    let email: String
    let img: String?
    let phone: String?
    let role: String
    let status: String
    
    var id: Int { userId }
}

struct CentralOffice: Identifiable, Codable {
    let id: Int
    let location: String
    let name: String?
    var officers: [CentralOfficer]
}

struct AddOfficerRequest: Encodable {
    let centralOfficeId: Int
    let centralOfficerName: String
    let centralOfficerEmail: String
    let phone: String?
}

