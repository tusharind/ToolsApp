import SwiftUI

struct FactoryManagerView: View {
    var body: some View {
        TabView {

            ManagersView()
                .navigationTitle("Products")

                .tabItem {
                    Label("Products", systemImage: "cube.box.fill")
                }

            AvailableManagersView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2.fill")
                }
        }
    }
}
