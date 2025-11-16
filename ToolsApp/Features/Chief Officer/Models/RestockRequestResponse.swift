import SwiftUI

struct RestockRequestResponse: Decodable {
    let success: Bool
    let message: String?
    let data: RestockRequest?
    let pagination: Pagination?
    let timestamp: String?
}

struct RestockRequest: Decodable, Identifiable {
    let id: Int
    let factoryId: Int
    let factoryName: String
    let productId: Int
    let productName: String
    let qtyRequested: Int
    let status: String
    let createdAt: String
    let completedAt: String?
    let currentFactoryStock: Int
    let centralOfficeStock: Int
}

struct CreateRestockRequestBody: Encodable {
    let factoryId: Int
    let productId: Int
    let qtyRequested: Int
}

struct RestockRequestListResponse: Decodable {
    let success: Bool
    let message: String?
    let data: RestockRequestPage?
    let pagination: Pagination?
    let timestamp: String?
}

struct RestockRequestPage: Decodable {
    let content: [RestockRequest]
    let pageable: Pageable
    let totalElements: Int
    let totalPages: Int
    let last: Bool
    let size: Int
    let number: Int
    let sort: Sort
    let numberOfElements: Int
    let first: Bool
    let empty: Bool
}

struct Sort: Decodable {
    let empty: Bool
    let sorted: Bool
    let unsorted: Bool
}



