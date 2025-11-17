import SwiftUI

struct StockProductionRequest: Codable {
    let productId: Int
    let quantity: Int
}

struct StockProductionResponse: Codable {
    let success: Bool
    let message: String
    let data: String?
    let pagination: String?
    let timestamp: String
}
