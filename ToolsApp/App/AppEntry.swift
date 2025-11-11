import SwiftUI

@main
struct ToolsAppApp: App {
    @StateObject var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
