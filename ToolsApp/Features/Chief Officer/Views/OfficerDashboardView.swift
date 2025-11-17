import SwiftUI

struct OfficerDashboardView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Links")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            QuickLinkCard(
                                title: "New Request",
                                systemImage: "receipt",
                                destination: ChiefOfficerDashboardView()
                            )
                            QuickLinkCard(
                                title: "Restock Requests",
                                systemImage: "text.page",
                                destination: RestockRequestsListView()
                            )
                            QuickLinkCard(
                                title: "Inventory",
                                systemImage: "truck.box.fill",
                                destination: CentralInventoryView()
                            )

                            .padding(.horizontal)
                        }

                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .navigationTitle("Officer Dashboard")
            }
        }
    }

}
