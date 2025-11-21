import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isAuthenticated {
                switch appState.role {
                case .owner:
                   AdminRootContainerView()
                case .chiefOfficer:
                   OfficerDashboardView()
                case .manager:
                    ManagerHomeView()
                case .chiefSupervisor:
                    ChiefSupervisorDashboardView()
                case .worker:
                    WorkerDashboardView()
                case .distributor:
                    DistributorDashboardView()
                case .none:
                    LoginView()
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}

struct AdminContentView: View {
    @Binding var selected: MenuOption
    let toggleMenu: () -> Void

    var body: some View {
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
            .navigationTitle(selected.rawValue)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: toggleMenu) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}

struct SideMenuContainerView<SideMenu: View, Content: View>: View {
    @Binding var isMenuOpen: Bool
    let menuWidth: CGFloat
    let shouldShowOverlay: Bool

    let sideMenu: () -> SideMenu
    let contentArea: () -> Content

    var body: some View {
        ZStack(alignment: .leading) {

            contentArea()
                .disabled(isMenuOpen && shouldShowOverlay)

            if isMenuOpen && shouldShowOverlay {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { toggleMenu() }
                    .transition(.opacity)
            }

            sideMenu()
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

    private func toggleMenu() {
        withAnimation { isMenuOpen.toggle() }
    }
}

struct AdminRootContainerView: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @State private var isMenuOpen: Bool = false
    @State private var selected: MenuOption = .dashboard

    private let menuWidth: CGFloat = 280

    var body: some View {
        GeometryReader { geo in
            SideMenuContainerView(
                isMenuOpen: $isMenuOpen,
                menuWidth: menuWidth,
                shouldShowOverlay: shouldShowOverlay
            ) {
                sideMenu
            } contentArea: {
                AdminContentView(selected: $selected, toggleMenu: toggleMenu)
            }
        }
    }

    private var shouldShowOverlay: Bool {
        hSizeClass == .compact
    }

    private var sideMenu: some View {
        SideMenuView(selected: $selected, isOpen: $isMenuOpen)
            .background(Color(UIColor.systemBackground))
            .shadow(radius: 2)
    }

    private func toggleMenu() {
        withAnimation { isMenuOpen.toggle() }
    }
}

