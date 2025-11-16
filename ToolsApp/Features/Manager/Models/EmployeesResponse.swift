import SwiftUI

struct MyFactoryResponse: Codable {
    let success: Bool
    let message: String
    let data: MyFactoryData
}

struct MyFactoryData: Codable {
    let employees: [FactoryWorkers]
    let totalCount: Int
    let factoryId: Int
    let factoryName: String
}
