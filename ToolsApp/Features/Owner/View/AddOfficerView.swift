import SwiftUI
struct AddOfficerView: View {
    let office: CentralOffice
    @ObservedObject var viewModel: CentralOfficerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Officer Details") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                    TextField("Phone", text: $phone)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button("Add Officer") {
                    Task {
                        await viewModel.addOfficer(to: office.id, name: name, email: email, phone: phone.isEmpty ? nil : phone)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Add Officer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
