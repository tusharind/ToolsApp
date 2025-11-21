import SwiftUI

struct CentralOfficesView: View {
    @StateObject private var viewModel = CentralOfficerViewModel()
    @State private var showAddOfficerForOffice: CentralOffice?
    @State private var officerToDelete: CentralOfficer?
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading offices...")
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.offices) { office in
                            OfficeSectionView(
                                office: office,
                                searchText: $viewModel.searchText,
                                onAddOfficer: {
                                    showAddOfficerForOffice = office
                                },
                                onDeleteOfficer: { officer in
                                    officerToDelete = officer
                                    showDeleteConfirmation = true
                                }
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle("Central Officers")
        .sheet(item: $showAddOfficerForOffice) { office in
            AddOfficerView(office: office, viewModel: viewModel)
        }
        .alert(
            "Delete Officer",
            isPresented: $showDeleteConfirmation,
            presenting: officerToDelete
        ) { officer in
            Button("Delete", role: .destructive) {
                Task { await viewModel.deleteOfficer(officerId: officer.id) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { officer in
            Text("Are you sure you want to delete \(officer.username)?")
        }
        .task {
            await viewModel.fetchOffices()
        }
    }
}
