import SwiftUI

struct QuickLinkCard<Destination: View>: View {
    let title: String
    let systemImage: String
    let destination: Destination
    @State private var isPressed = false

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 32))
                    .foregroundColor(.blue)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(CardButtonStyle(isPressed: $isPressed))
    }
}
