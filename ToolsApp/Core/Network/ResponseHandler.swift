import SwiftUI

enum ResponseHandler { ///pure utility logic (enum is used for grouping mechanism)
    static func decodeResponse<T: Decodable>(_ data: Data, responseType: T.Type) throws -> T { ///why is response handler an enum
        do {
            return try JSONDecoder.configured.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

