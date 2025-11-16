import SwiftUI

enum ResponseHandler {
    static func decodeResponse<T: Decodable>(_ data: Data, responseType: T.Type) throws -> T {
        do {
            return try JSONDecoder.configured.decode(T.self, from: data)
        } catch {
            print("DECODING ERROR:", error)
            
            

            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type mismatch:", type, context.debugDescription)
                    print("CodingPath:", context.codingPath)
                case .valueNotFound(let type, let context):
                    print("Value not found:", type, context.debugDescription)
                    print("CodingPath:", context.codingPath)
                case .keyNotFound(let key, let context):
                    print("Key not found:", key, context.debugDescription)
                    print("CodingPath:", context.codingPath)
                case .dataCorrupted(let context):
                    print("Data corrupted:", context.debugDescription)
                    print("CodingPath:", context.codingPath)
                @unknown default:
                    print("Unknown decoding error")
                }
            }

            throw error
        }
    }
}

