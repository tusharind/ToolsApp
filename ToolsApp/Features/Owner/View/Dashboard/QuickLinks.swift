import SwiftUI

var quickLinksSection: some View {
    VStack(alignment: .leading, spacing: 16) {
        Text("Quick Links")
            .font(.title2)
            .bold()
            .padding(.horizontal)

        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 16
        ) {
            QuickLinkCard(
                title: "Factory Products",
                systemImage: "shippingbox.fill",
                destination: ProductsListView()
            )

            QuickLinkCard(
                title: "Factory List",
                systemImage: "building.2.fill",
                destination: FactoriesListView()
            )

            QuickLinkCard(
                title: "Central Office",
                systemImage: "globe.central.south.asia.fill",
                destination: CentralOfficesView()
            )

            QuickLinkCard(
                title: "Employees",
                systemImage: "person.3.sequence",
                destination: EmployeeListView()
            )

            QuickLinkCard(
                title: "Categories",
                systemImage: "paperclip",
                destination: ToolCategoriesListView()
            )

            QuickLinkCard(
                title: "Managers",
                systemImage: "books.vertical.circle.fill",
                destination: FactoryManagerView()
            )
        
        }
        .padding(.horizontal)
        
        QuickLinkCard(
            title: "Tools",
            systemImage: "hammer.fill",
            destination: ToolsListView()
        )
        .padding(.horizontal)
    }
    .padding(.vertical)
}



