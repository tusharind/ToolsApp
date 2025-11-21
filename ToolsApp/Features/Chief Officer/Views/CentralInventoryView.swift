import SwiftUI

struct CentralInventoryView: View {
    @StateObject private var viewModel = CentralInventoryViewModel()

    var body: some View {
        NavigationStack {
            VStack {

                VStack(spacing: 10) {

                    HStack {
                        TextField("Product ID", text: $viewModel.productId)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        TextField("Min Qty", text: $viewModel.minQuantity)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)

                        TextField("Max Qty", text: $viewModel.maxQuantity)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    Picker("Sort by", selection: $viewModel.sortBy) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    Button("Apply Filters") {
                        Task { await viewModel.applyFilters() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()

                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red)

                    } else if viewModel.filteredItems.isEmpty {
                        Text("No inventory found").foregroundColor(.secondary)

                    } else {
                        List(viewModel.filteredItems) { item in
                            VStack(alignment: .leading) {
                                Text(item.productName).font(.headline)
                                HStack {
                                    Text("Quantity: \(item.quantity)")
                                    Spacer()
                                    Text(
                                        "Total Received: \(item.totalReceived)"
                                    )
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .searchable(text: $viewModel.searchText)
            }
            .navigationTitle("Central Office Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.applyFilters()
            }
        }
    }
}
