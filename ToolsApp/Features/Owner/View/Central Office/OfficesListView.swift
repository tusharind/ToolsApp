import SwiftUI

struct OfficesListView: View {
    @StateObject private var viewModel = CentralOfficerViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading offices...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.offices) { office in
                        NavigationLink(
                            destination: OfficersListView(
                                office: office,
                                viewModel: viewModel
                            )
                        ) {
                            HStack {
                                Text(office.name ?? office.location)
                                    .font(.headline)
                                Spacer()
                                Text("\(office.officers.count) officers")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Central Offices")
        .task {
            await viewModel.fetchOffices()
        }
    }
}
