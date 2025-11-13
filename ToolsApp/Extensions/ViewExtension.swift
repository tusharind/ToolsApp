import SwiftUI

extension View {
    func cardStyle() -> some View {
        self.padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
    }
}
