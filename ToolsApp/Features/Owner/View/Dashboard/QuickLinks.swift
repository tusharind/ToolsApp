import SwiftUI

var quickLinksSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        Text("Quick Links")
            .font(.title2)
            .bold()

        VStack {
            HStack {
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
            }
            HStack {
                QuickLinkCard(
                    title: "Central Office",
                    systemImage: "globe.central.south.asia.fill",
                    destination: CentralOfficesView()
                )
            }
            HStack {
                QuickLinkCard(
                    title: "Employees",
                    systemImage: "person.3.sequence",
                    destination: ManagersView()
                )
            }
        }
    }
}

