import SwiftUI

struct PendingRestockRequestsView: View {
    @StateObject private var viewModel = RestockRequestsViewModel()
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task { await viewModel.fetchRestockRequests() }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.restockRequests.isEmpty {
                    Text("No restock requests found.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.restockRequests) { request in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(request.productName)
                                .font(.headline)
                            Text("Requested Qty: \(request.qtyRequested)")
                                .font(.subheadline)
                            Text(
                                "Current Stock: \(request.currentFactoryStock)"
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            Text("Created At: \(request.createdAt)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if request.status.uppercased() == "PENDING" {
                                Button("Mark as Completed") {
                                    Task {
                                        await viewModel.completeRequest(request)
                                        { success, message in
                                            if !success, let msg = message {
                                                alertMessage = msg
                                                showAlert = true
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Restock Requests")
            .task {
                await viewModel.fetchRestockRequests()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Notice"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
