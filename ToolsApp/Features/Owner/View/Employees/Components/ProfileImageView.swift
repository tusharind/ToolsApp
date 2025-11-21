import SwiftUI

struct ProfileImageView: View {
    let urlString: String?

    var body: some View {
        if let urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty: ProgressView().frame(width: 60, height: 60)
                case .success(let image):
                    image.resizable().scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                case .failure: placeholder
                @unknown default: placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundColor(.gray)
    }
}
