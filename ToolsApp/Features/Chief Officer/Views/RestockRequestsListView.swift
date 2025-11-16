import SwiftUI

struct RestockRequestsListView: View {
    @StateObject private var viewModel = CreateRestockRequestViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoadingMyRequests {
                    ProgressView("Loading…")
                } else if let error = viewModel.myRequestsError {
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task { await viewModel.fetchMyRestockRequests() }
                        }
                        .padding(.top, 4)
                    }
                } else if viewModel.myRequests.isEmpty {
                    Text("No restock requests found.")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.myRequests) { request in
                        RestockRequestRow(request: request)
                            .listRowSeparator(.visible)
                    }
                }
            }
            .navigationTitle("My Restock Requests")
            .task {
                await viewModel.fetchMyRestockRequests()
            }
        }
    }
}
