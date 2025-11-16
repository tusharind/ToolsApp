import SwiftUI

final class LoggerInterceptor {
    static let shared = LoggerInterceptor()
    private init() {}

    func logRequest(_ request: URLRequest) {
        if let body = request.httpBody,
                  let bodyString = String(data: body, encoding: .utf8) {
                   print("BODY: \(bodyString)")
               } else {
                   print("BODY: EMPTY")
               }
        
        print(
            "\(request.httpMethod ?? ""): \(request.url?.absoluteString ?? "")"
        )
    }

    func logResponse(_ data: Data, response: URLResponse?) {
        print("----- RESPONSE START -----")

        if let http = response as? HTTPURLResponse {
            print("STATUS:", http.statusCode)
            print("HEADERS:", http.allHeaderFields)
        } else {
            print("No HTTP response")
        }

        print("RAW BYTES:", data.count)

        if data.count == 0 {
            print("BODY: <EMPTY>")
        } else {
            let bodyString = String(data: data, encoding: .utf8) ?? "<non-UTF8>"
            print("BODY:", bodyString)
        }

        print("----- RESPONSE END -----")
    }

}
