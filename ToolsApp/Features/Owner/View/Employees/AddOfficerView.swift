import SwiftUI

struct AddOfficerView: View {
    let office: CentralOffice
    @ObservedObject var viewModel: CentralOfficerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationView {
            Form {
                Section("Officer Details") {
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField("Phone", text: $phone)
                        .keyboardType(.numberPad)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                Section {
                    Button {
                        Task {
                            await submitOfficer()
                        }
                    } label: {
                        if isSubmitting {
                            HStack {
                                ProgressView()
                                Text("Adding...")
                            }
                        } else {
                            Text("Add Officer")
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
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

    private var isFormValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        let nameRegex = "^[A-Za-z ]+$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        guard nameTest.evaluate(with: trimmedName), !trimmedName.isEmpty else {
            return false
        }

        let emailRegex = #"^\S+@\S+\.\S+$"#
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailTest.evaluate(with: trimmedEmail) else { return false }

        if !trimmedPhone.isEmpty {
            let phoneRegex = #"^\d{10}$"#
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            guard phoneTest.evaluate(with: trimmedPhone) else { return false }
        }

        return true
    }

    private func submitOfficer() async {
        isSubmitting = true
        defer { isSubmitting = false }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        viewModel.errorMessage = nil

        let success = await viewModel.addOfficer(
            to: office.id,
            name: trimmedName,
            email: trimmedEmail,
            phone: trimmedPhone.isEmpty ? nil : trimmedPhone
        )

        if success {
            dismiss()
        }
    }

}
