import SwiftUI

struct RootCategoryView: View {
    @State private var selectedTab = 0
    @State private var isAddCategoryPresented = true  
    var body: some View {
        TabView(selection: $selectedTab) {
            
            CategoriesListView()
                .tabItem {
                    Label("Category", systemImage: "folder")
                }
                .tag(0)
            
           ToolCategoriesListView()
                .tabItem {
                    Label("Tool Category", systemImage: "wrench")
                }
                .tag(1)
        }
    }
}
