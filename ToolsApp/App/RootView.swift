import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isAuthenticated {
                switch appState.role {
                case .owner:
                   OwnerDashboardView()
                case .chiefOfficer:
                    ManagerHomeView()
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
