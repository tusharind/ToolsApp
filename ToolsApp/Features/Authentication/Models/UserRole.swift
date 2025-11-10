import SwiftUI

enum UserRole: String, Codable {
    case worker
    case chiefSupervisor = "chief supervisor"
    case manager
    case chiefOfficer = "chief officer"
    case owner
    case distributor
}
