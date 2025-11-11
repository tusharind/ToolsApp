import SwiftUI

@main
struct ToolsAppApp: App {
    @StateObject private var appState = AppState() //appstate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
