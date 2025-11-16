import SwiftUI

struct FactoryManagerView: View {
    var body: some View {
        TabView {

            ManagersView()
                .navigationTitle("Managers")

                .tabItem {
                    Label("Assigned", systemImage: "list.bullet.rectangle.portrait")
                }

            AvailableManagersView()
                .tabItem {
                    Label("Available", systemImage: "text.page.badge.magnifyingglass")
                }
        }
    }
}

