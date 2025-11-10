import SwiftUI

struct NetworkConfig {
    let baseURL: String
    let timeout: TimeInterval
    
    static let `default` = NetworkConfig(
        baseURL: "https://herschel-hyperneurotic-hilma.ngrok-free.dev",
        timeout: 120
    )
}
