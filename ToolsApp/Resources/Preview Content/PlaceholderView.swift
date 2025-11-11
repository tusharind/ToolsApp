import SwiftUI

struct PlaceholderView: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(title)
                .font(.title2)
                .bold()
            Text("Coming soon...")
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

struct WorkerDashboardView: View {
    var body: some View {
        Text("Distributor Dashboard (Coming Soon)")
            .font(.title2)
            .foregroundColor(.gray)
            .padding()
    }
}
