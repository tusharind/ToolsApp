import SwiftUI

struct ValidatedTextField: View {
    let title: String
    @Binding var text: String
    @Binding var touched: Bool
    var keyboard: UIKeyboardType = .default
    var errorMessage: String
    var validator: ((String) -> Bool)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(title, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .onChange(of: text) { _, _ in
                    touched = true
                }
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            if touched && !isValid {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .animation(.easeInOut, value: touched)
    }

    private var isValid: Bool {
        validator?(text) ?? !text.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }
}
