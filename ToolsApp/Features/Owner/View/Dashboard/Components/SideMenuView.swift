import SwiftUI

struct SideMenuView: View {
    @Binding var selected: MenuOption
    @Binding var isOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(MenuOption.allCases) { option in
                        menuRow(for: option)
                    }
                }
                .padding(.vertical)
            }

            Spacer()

        }
        .padding(.top, 8)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Admin")
                    .font(.headline)
                Text("owner@gmail.com")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .lineLimit(1)

            Spacer()

            Button(action: { withAnimation { isOpen = false } }) {
                Image(systemName: "xmark")
                    .padding(8)
                    .background(Color(UIColor.tertiarySystemFill))
                    .clipShape(Circle())
            }
            .opacity(UIDevice.current.userInterfaceIdiom == .phone ? 1 : 0)
        }
        .padding([.horizontal, .top])
        .padding(.bottom, 8)
    }

    private func menuRow(for option: MenuOption) -> some View {
        Button(action: {
            withAnimation {
                selected = option

                if UIDevice.current.userInterfaceIdiom == .phone {
                    isOpen = false
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: option.systemImageName)
                    .frame(width: 28, height: 28)
                    .imageScale(.large)

                Text(option.rawValue)
                    .font(.system(size: 16, weight: .medium))

                Spacer()

                if selected == option {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(
                selected == option ? Color.accentColor : Color.primary
            )
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(
                selected == option
                    ? Color.accentColor.opacity(0.12) : Color.clear
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
    }

}
