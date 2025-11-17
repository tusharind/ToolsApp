import SwiftUI

private struct ManagerSelectionList: View {
    let managers: [Manager]
    @Binding var selectedId: Int?

    var body: some View {
        List(managers, selection: $selectedId) { manager in
            HStack {
                Text("\(manager.username) id:\(manager.id)")

                    .font(.body)

                Spacer()

                if selectedId == manager.id {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .transition(.opacity)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.snappy) {
                    selectedId = manager.id
                }
            }
        }
        .listStyle(.plain)
        .frame(minHeight: 200)
        .animation(.default, value: selectedId)
    }
}
