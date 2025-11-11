import SwiftUI

final class APIClient {
    static let shared = APIClient()
    private let session: URLSession
    private let config: NetworkConfig

    init(session: URLSession = .shared, config: NetworkConfig = .default) {
        self.session = session
        self.config = config
    }

    func send<T: Decodable>(_ request: APIRequest, responseType: T.Type)
        async throws -> T
    {
        var urlRequest = try request.buildURLRequest(with: config)
        AuthInterceptor.shared.intercept(&urlRequest)
        LoggerInterceptor.shared.logRequest(urlRequest)

        let (data, response) = try await session.data(for: urlRequest)
        LoggerInterceptor.shared.logResponse(data, response: response)
        return try ResponseHandler.decodeResponse(data, responseType: T.self)
    }
}
