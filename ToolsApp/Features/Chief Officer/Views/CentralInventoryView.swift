import SwiftUI

struct CentralInventoryView: View {
    @StateObject private var viewModel = CentralInventoryViewModel()

    @State private var productId: String = ""
    @State private var minQuantity: String = ""
    @State private var maxQuantity: String = ""
    @State private var sortBy: SortOption = .id
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            VStack {

                VStack(spacing: 10) {
                    HStack {
                        TextField("Product ID", text: $productId)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        TextField("Min Qty", text: $minQuantity)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        TextField("Max Qty", text: $maxQuantity)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                    }

                    Picker("Sort by", selection: $sortBy) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)

                    Button("Apply Filters") {
                        Task {
                            await applyFilters()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()

                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading inventory…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if filteredItems.isEmpty {
                        Text("No inventory found")
                            .foregroundColor(.secondary)
                    } else {
                        List(filteredItems) { item in
                            VStack(alignment: .leading) {
                                Text(item.productName)
                                    .font(.headline)
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
                .searchable(text: $searchText, prompt: "Search product")
            }
            .navigationTitle("Central Office Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await applyFilters()
            }
        }
    }

    private var filteredItems: [InventoryItem] {
        var items = viewModel.inventoryItems

        if !searchText.isEmpty {
            items = items.filter {
                $0.productName.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch sortBy {
        case .id: items.sort { $0.productId < $1.productId }
        case .name:
            items.sort {
                $0.productName.lowercased() < $1.productName.lowercased()
            }
        case .quantity: items.sort { $0.quantity < $1.quantity }
        case .totalReceived: items.sort { $0.totalReceived < $1.totalReceived }
        }

        return items
    }

    private func applyFilters() async {
        let pid = Int(productId)
        let minQ = Int(minQuantity)
        let maxQ = Int(maxQuantity)
        await viewModel.fetchInventory(
            productId: pid,
            minQuantity: minQ,
            maxQuantity: maxQ
        )
    }
}
