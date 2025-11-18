import SwiftUI

struct FactoryCard: View {
    let factory: Factory
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(factory.name)
                .font(.headline)

            let city = factory.city
            Text(city)
                .font(.caption)
                .foregroundColor(.secondary)

        }
        .padding()
        .frame(width: 150, height: 90)
        .background(
            isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}
