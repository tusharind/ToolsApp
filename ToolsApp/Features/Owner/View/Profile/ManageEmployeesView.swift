import SwiftUI

struct ManageEmployeesView: View {
    var body: some View {
        NavigationStack {
            VStack {
                TabView {
                    // MARK: - Managers Tab
                    ManagersView()
                        .tabItem {
                            Label("Managers", systemImage: "person.2.fill")
                        }
                    
                    // MARK: - Chief Supervisors Tab
                    VStack {
                        Text("Chief Supervisors list coming soon")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    }
                    .tabItem {
                        Label("Chief Supervisors", systemImage: "person.text.rectangle.fill")
                    }
                    
                    // MARK: - Workers Tab
                    VStack {
                        Text("Workers list coming soon")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    }
                    .tabItem {
                        Label("Workers", systemImage: "person.3.fill")
                    }
                }
            }
            .navigationTitle("Manage Employees")
        }
    }
}



#Preview {
    ManageEmployeesView()
}
