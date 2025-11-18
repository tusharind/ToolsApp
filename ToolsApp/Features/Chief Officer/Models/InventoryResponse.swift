import SwiftUI

struct InventoryResponse: Decodable {
    let success: Bool
    let message: String
    let data: InventoryData?
}

struct InventoryData: Decodable {
    let content: [InventoryItem]
    let totalElements: Int
    let pageNumber: Int?
    let pageSize: Int?
}

struct InventoryItem: Identifiable, Decodable {
    let id = UUID()
    let productId: Int
    let productName: String
    let quantity: Int
    let totalReceived: Int
}
