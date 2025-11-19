import Charts
import SwiftUI

@MainActor
struct OwnerDashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var navigateToProfile = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                metricsSection
                chartsSection(vm: viewModel)
            }
            .padding()
        }
        .navigationTitle("Admin Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    navigateToProfile = true
                } label: {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }
            }
        }
        .background(
            NavigationLink(
                destination: AdminProfileView(),
                isActive: $navigateToProfile
            ) {
                EmptyView()
            }
            .hidden()
        )
        .task {
            await viewModel.fetchAllMetrics()
        }

    }

    private func chartsSection(vm: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Analytics")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
                Text("Products per Category")
                    .font(.headline)

                Chart(vm.categoryProductCounts, id: \.categoryId) { item in
                    SectorMark(
                        angle: .value("Count", item.productCount),
                        innerRadius: .ratio(0.4),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Category", item.categoryName))
                }
                .frame(height: 260)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }

            if !vm.factoryInventoryTotals.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Stock Distribution by Factory")
                        .font(.headline)

                    Chart(vm.factoryInventoryTotals, id: \.factoryId) { item in
                        SectorMark(
                            angle: .value("Stock", item.totalCount),
                            innerRadius: .ratio(0.4),
                            angularInset: 2
                        )
                        .foregroundStyle(
                            by: .value("Factory", item.factoryName)
                        )
                    }
                    .frame(height: 260)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Metrics")
                .font(.title2)
                .bold()

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.bottom, 4)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.metrics) { metric in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(metric.title)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let value = viewModel.value(for: metric) {
                                Text(value)
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(metric.color)
                            } else if viewModel.isLoading {
                                ProgressView()
                                    .tint(metric.color)
                            } else {
                                Text("\(viewModel.productCount ?? 0)")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(width: 180, height: 100, alignment: .leading)
                        .background(metric.color.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
    OwnerDashboardView()
}

enum MenuOption: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case products = "Factory Products"
    case factories = "Factory List"
    case centralOffices = "Central Office"
    case employees = "Employees"
    case categories = "Categories"
    case managers = "Managers"
    case tools = "Tools"
    case profile = "Profile"

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .dashboard: return "speedometer"
        case .products: return "shippingbox.fill"
        case .factories: return "building.2.fill"
        case .centralOffices: return "globe.central.south.asia.fill"
        case .employees: return "person.3.sequence"
        case .categories: return "folder"
        case .managers: return "books.vertical.circle.fill"
        case .tools: return "hammer.fill"
        case .profile: return "person.circle.fill"
        }
    }
}

struct AdminRootContainerView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @State private var isMenuOpen: Bool = false
    @State private var selected: MenuOption = .dashboard

    private let menuWidth: CGFloat = 280

    var body: some View {
        GeometryReader { geo in

            ZStack(alignment: .leading) {
      
                contentArea
                    .frame(width: geo.size.width, height: geo.size.height)
                    .disabled(isMenuOpen && shouldShowOverlay)  // optional

                if isMenuOpen && shouldShowOverlay {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { toggleMenu() }
                        .transition(.opacity)
                }

                sideMenu
                    .frame(width: menuWidth)
                    .offset(x: isMenuOpen ? 0 : -menuWidth)
                    .animation(
                        .interactiveSpring(
                            response: 0.35,
                            dampingFraction: 0.8
                        ),
                        value: isMenuOpen
                    )
            }

        }
    }

    private var shouldShowOverlay: Bool {

        return hSizeClass == .compact
    }

    private var sideMenu: some View {
        SideMenuView(selected: $selected, isOpen: $isMenuOpen)
            .background(Color(UIColor.systemBackground))
            .shadow(radius: 2)
    }

    private var contentArea: some View {
        NavigationStack {
            ZStack {
                Group {
                    switch selected {
                    case .dashboard:
                        OwnerDashboardView()
                    case .products:
                        ProductsListView()
                    case .factories:
                        FactoriesListView()
                    case .centralOffices:
                        CentralOfficesView()
                    case .employees:
                        EmployeeListView()
                    case .categories:
                        RootCategoryView()
                    case .managers:
                        FactoryManagerView()
                    case .tools:
                        ToolsListView()
                    case .profile:
                        AdminProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { toggleMenu() }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                    }
                }
            }
        }
    }

    private var navigationTitle: String {
        selected.rawValue
    }

    private func toggleMenu() {
        withAnimation { isMenuOpen.toggle() }
    }
}

struct SideMenuView: View {
    @Binding var selected: MenuOption
    @Binding var isOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(MenuOption.allCases) { option in
                        menuRow(for: option)
                    }
                }
                .padding(.vertical)
            }

            Spacer()

        }
        .padding(.top, 8)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Admin")
                    .font(.headline)
                Text("owner@gmail.com")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .lineLimit(1)

            Spacer()


            Button(action: { withAnimation { isOpen = false } }) {
                Image(systemName: "xmark")
                    .padding(8)
                    .background(Color(UIColor.tertiarySystemFill))
                    .clipShape(Circle())
            }
            .opacity(UIDevice.current.userInterfaceIdiom == .phone ? 1 : 0)
        }
        .padding([.horizontal, .top])
        .padding(.bottom, 8)
    }

    private func menuRow(for option: MenuOption) -> some View {
        Button(action: {
            withAnimation {
                selected = option
  
                if UIDevice.current.userInterfaceIdiom == .phone {
                    isOpen = false
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: option.systemImageName)
                    .frame(width: 28, height: 28)
                    .imageScale(.large)

                Text(option.rawValue)
                    .font(.system(size: 16, weight: .medium))

                Spacer()

                if selected == option {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(
                selected == option ? Color.accentColor : Color.primary
            )
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(
                selected == option
                    ? Color.accentColor.opacity(0.12) : Color.clear
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
    }

}
