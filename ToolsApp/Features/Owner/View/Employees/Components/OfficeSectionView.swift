import SwiftUI

struct OfficeSectionView: View {
    let office: CentralOffice
    @Binding var searchText: String
    var onAddOfficer: () -> Void
    var onDeleteOfficer: (CentralOfficer) -> Void

    var filteredOfficers: [CentralOfficer] {
        office.officers.filter { officer in
            searchText.isEmpty
                || officer.username.lowercased().contains(
                    searchText.lowercased()
                )
                || officer.email.lowercased().contains(searchText.lowercased())
                || (officer.phone?.contains(searchText) ?? false)
        }
    }

    var body: some View {
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
                TextField("Search officer", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 8)

                Button(action: onAddOfficer) {
                    Image(systemName: "plus")
                        .padding(8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)

            ForEach(filteredOfficers) { officer in
                OfficerRowView(
                    officer: officer,
                    onDelete: { onDeleteOfficer(officer) }
                )
            }
        }
        .padding(.vertical, 8)
    }
}
