import SwiftUI

enum APIEndpoints {
    static let login = "/auth/login"
    static let register = "/auth/register"
    
    static let fetchTools = "/worker/tools"
    static let requestTool = "/worker/request"
    
    static let approveRequest = "/chief/approve"
    static let restock = "/manager/restock"
    
    static let analytics = "/chiefOfficer/analytics"
    static let createFactory = "/owner/createFactory"
    static let getFactory = "/owner/factories"
    static let name = "/name"
    static let allAdminproducts = "admin/products"
    static let deleteFactory = "/owner/deleteFactory"
}
