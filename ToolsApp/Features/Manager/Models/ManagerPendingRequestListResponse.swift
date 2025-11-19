import SwiftUI

struct ManagerPendingRequestListResponse: Decodable {
    let success: Bool
    let message: String?
    let data: ManagerPendingRequestData?
}

struct ManagerPendingRequestSingleResponse: Decodable {
    let success: Bool
    let message: String?
    let data: ManagerPendingRequest?
}
