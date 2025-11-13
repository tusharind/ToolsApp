import UIKit
import SwiftUI

struct MultipartFormDataBuilder {
    private let boundary = UUID().uuidString
    private var body = Data()
    
    mutating func addField(name: String, value: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }
    
    mutating func addImageField(name: String, image: UIImage, filename: String = "image.jpg") {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
    }
    
    mutating func finalize() -> (data: Data, boundary: String) {
        body.append("--\(boundary)--\r\n")
        return (body, boundary)
    }
}
