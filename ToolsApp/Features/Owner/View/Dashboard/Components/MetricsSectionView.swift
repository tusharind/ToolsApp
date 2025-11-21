import SwiftUI

struct MetricsSectionView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Metrics")
                .font(.title2)
                .bold()

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.bottom, 4)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.metrics) { metric in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(metric.title)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let value = viewModel.value(for: metric) {
                                Text(value)
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(metric.color)
                            } else if viewModel.isLoading {
                                ProgressView()
                                    .tint(metric.color)
                            } else {
                                Text("0")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(width: 180, height: 100, alignment: .leading)
                        .background(metric.color.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}
