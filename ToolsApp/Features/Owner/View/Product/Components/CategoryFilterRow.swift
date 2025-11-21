import SwiftUI

struct CategoryFilterRow: View {
    @ObservedObject var vm: ProductsViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FactoryButton(
                    title: "All",
                    isSelected: vm.selectedCategoryId == nil
                ) {
                    vm.selectedCategoryId = nil
                    Task { await vm.fetchProducts() }
                }

                ForEach(vm.categories, id: \.id) { cat in
                    FactoryButton(
                        title: cat.categoryName,
                        isSelected: vm.selectedCategoryId == cat.id
                    ) {
                        vm.selectedCategoryId = cat.id
                        Task { await vm.fetchProducts() }
                    }
                }
            }
            .padding(.horizontal)
        }

    }
}

struct StatusFilterRow: View {
    @ObservedObject var vm: ProductsViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FactoryButton(
                    title: "All",
                    isSelected: vm.selectedStatus == nil
                ) {
                    vm.selectedStatus = nil
                    Task { await vm.fetchProducts() }
                }
                FactoryButton(
                    title: "Active",
                    isSelected: vm.selectedStatus == "ACTIVE"
                ) {
                    vm.selectedStatus = "ACTIVE"
                    Task { await vm.fetchProducts() }
                }
                FactoryButton(
                    title: "Inactive",
                    isSelected: vm.selectedStatus == "INACTIVE"
                ) {
                    vm.selectedStatus = "INACTIVE"
                    Task { await vm.fetchProducts() }
                }
            }
            .padding(.horizontal)
        }
    }
}
