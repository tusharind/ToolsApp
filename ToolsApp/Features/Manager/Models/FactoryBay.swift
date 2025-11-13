import Foundation

struct Bay: Identifiable, Codable, Hashable { 
    let id: Int
    let name: String
    let description: String
    let factoryId: Int
    let factoryName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "bayId"
        case name
        case description
        case factoryId
        case factoryName
    }
}

struct BayResponse: Codable {
    let success: Bool
    let message: String
    let data: [Bay]
    let pagination: Pagination?
    let timestamp: String?
}


