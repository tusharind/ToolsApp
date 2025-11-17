struct FactoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(10)
        }
    }
}