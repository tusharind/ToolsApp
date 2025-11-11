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
                    Text("")
                case .manager:
                    ManagerDashboardView()
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

struct ManagerDashboardView: View {
    var body: some View {
        Text("Manager Dashboard (Coming Soon)")
            .font(.title2)
            .foregroundColor(.gray)
            .padding()
    }
}

struct ChiefSupervisorDashboardView: View {
    var body: some View {
        Text("Chief Supervisor Dashboard (Coming Soon)")
            .font(.title2)
            .foregroundColor(.gray)
            .padding()
    }
}

struct DistributorDashboardView: View {
    var body: some View {
        Text("Distributor Dashboard (Coming Soon)")
            .font(.title2)
            .foregroundColor(.gray)
            .padding()
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
