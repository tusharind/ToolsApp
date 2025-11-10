import SwiftUI

struct OfficersListView: View {
    let office: CentralOffice
    @ObservedObject var viewModel: CentralOfficerViewModel
    @State private var showAddOfficer = false
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search officer", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    showAddOfficer = true
                }
            }
            .padding()
            
            List(viewModel.filteredOfficers(for: office)) { officer in
                VStack(alignment: .leading) {
                    Text(officer.username)
                        .font(.headline)
                    Text(officer.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    if let phone = officer.phone {
                        Text(phone)
                            .font(.subheadline)
                    }
                    Text(officer.role)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle(office.name ?? office.location)
        .sheet(isPresented: $showAddOfficer) {
            AddOfficerView(office: office, viewModel: viewModel)
        }
    }
}
