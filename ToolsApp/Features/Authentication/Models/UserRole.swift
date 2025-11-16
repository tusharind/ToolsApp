import SwiftUI

enum UserRole: String, Codable {
    case worker
    case chiefSupervisor = "chief supervisor"
    case manager
    case chiefOfficer = "CENTRAL_OFFICER"
    case owner = "OWNER"
    case distributor
}
