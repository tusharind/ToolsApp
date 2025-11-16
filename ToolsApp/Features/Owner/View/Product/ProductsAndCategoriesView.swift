import SwiftUI

struct ProductsAndCategoriesView: View {
    var body: some View {
        TabView {

            ProductsListView()
                .navigationTitle("Products")

                .tabItem {
                    Label("Products", systemImage: "cube.box.fill")
                }

            ToolCategoriesListView()
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2.fill")
                }
        }
    }
}
