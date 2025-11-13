import SwiftUI

struct CentralOfficesView: View {
    @StateObject private var viewModel = CentralOfficerViewModel()
    @State private var showAddOfficerForOffice: CentralOffice?
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading offices...")
                    .padding()
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.offices) { office in
                            
                            VStack(spacing: 12) {
      
                                HStack {
                                    Text(office.name ?? office.location)
                                        .font(.headline)
                                    Spacer()
                                    Text("\(office.officers.count) officers")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                                
                                HStack(spacing: 12) {
                                    TextField("Search officer", text: $viewModel.searchText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding(.leading, 8)
                                    
                                    Button {
                                        showAddOfficerForOffice = office
                                    } label: {
                                        Image(systemName: "plus")
                                            .padding(8)
                                            .background(Color.accentColor)
                                            .foregroundColor(.white)
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(.horizontal)
                                
                                let filtered = office.officers.filter { officer in
                                    viewModel.searchText.isEmpty ||
                                    officer.username.lowercased().contains(viewModel.searchText.lowercased()) ||
                                    officer.email.lowercased().contains(viewModel.searchText.lowercased()) ||
                                    (officer.phone?.contains(viewModel.searchText) ?? false)
                                }
                                
                                ForEach(filtered) { officer in
                                    HStack(alignment: .top, spacing: 12) {
                             
                                        if let imgUrl = officer.img, let url = URL(string: imgUrl) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                        .frame(width: 60, height: 60)
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 60, height: 60)
                                                        .clipShape(Circle())
                                                case .failure:
                                                    Image(systemName: "person.crop.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 60, height: 60)
                                                        .foregroundColor(.gray)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        } else {
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(officer.username)
                                                    .font(.headline)
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                
                                                Spacer()
                                                
                                                Text(officer.role)
                                                    .font(.caption)
                                                    .padding(4)
                                                    .background(Color.blue.opacity(0.2))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(6)
                                            }
                                            
                                            Text(officer.email)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                            
                                            if let phone = officer.phone {
                                                Text(phone)
                                                    .font(.subheadline)
                                                    .foregroundColor(.green)
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                            }
                                            
                                            Text("Status: \(officer.status)")
                                                .font(.caption2)
                                                .foregroundColor(statusColor(officer.status))
                                                .padding(4)
                                                .background(statusColor(officer.status).opacity(0.2))
                                                .cornerRadius(4)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 140)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .navigationTitle("Central Offices")
        .sheet(item: $showAddOfficerForOffice) { office in
            AddOfficerView(office: office, viewModel: viewModel)
        }
        .task {
            await viewModel.fetchOffices()
        }
    }
    
    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "inactive": return .red
        case "pending": return .orange
        default: return .blue
        }
    }
}

