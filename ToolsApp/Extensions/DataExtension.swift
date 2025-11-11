import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }

    mutating func appendFormField(named name: String, value: String?, boundary: String) {
        guard let value = value, !value.isEmpty else { return } 
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        append("\(value)\r\n")
    }

    mutating func appendFileField(named name: String, fileName: String, mimeType: String, fileData: Data, boundary: String) {
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        append("Content-Type: \(mimeType)\r\n\r\n")
        append(fileData)
        append("\r\n")
    }
}
