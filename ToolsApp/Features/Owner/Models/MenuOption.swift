import SwiftUI

enum MenuOption: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case products = "Factory Products"
    case factories = "Factory List"
    case centralOffices = "Central Office"
    case employees = "Employees"
    case categories = "Categories"
    case managers = "Managers"
    case tools = "Tools"
    case profile = "Profile"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .dashboard: return "speedometer"
        case .products: return "shippingbox.fill"
        case .factories: return "building.2.fill"
        case .centralOffices: return "globe.central.south.asia.fill"
        case .employees: return "person.3.sequence"
        case .categories: return "folder"
        case .managers: return "books.vertical.circle.fill"
        case .tools: return "hammer.fill"
        case .profile: return "person.circle.fill"
        }
    }
}
