import SwiftUI

struct WorkerRow: View {
    let worker: FactoryWorkers

    var body: some View {
        HStack(spacing: 12) {
            if let img = worker.img, let url = URL(string: img) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(worker.username.prefix(1)).uppercased())
                            .font(.headline)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(worker.username)
                    .font(.headline)
                Text(worker.role)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(worker.phone)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
