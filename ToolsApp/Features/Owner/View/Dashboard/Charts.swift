import Charts
import SwiftUI

var chartsSection: some View {
    VStack(alignment: .leading, spacing: 24) {
        Text("Analytics")
            .font(.title2)
            .bold()

        VStack(alignment: .leading, spacing: 12) {
            Text("Sales by Factory (Month-wise)")
                .font(.headline)

            Chart {
                BarMark(
                    x: .value("Month", "Jan"),
                    y: .value("Sales", 12000)
                )
                BarMark(
                    x: .value("Month", "Feb"),
                    y: .value("Sales", 16000)
                )
                BarMark(
                    x: .value("Month", "Mar"),
                    y: .value("Sales", 19000)
                )
            }
            .frame(height: 220)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }

        VStack(alignment: .leading, spacing: 12) {
            Text("Product Growth Trend")
                .font(.headline)

            Chart {
                LineMark(x: .value("Month", "Jan"), y: .value("Growth", 20))
                LineMark(x: .value("Month", "Feb"), y: .value("Growth", 35))
                LineMark(x: .value("Month", "Mar"), y: .value("Growth", 60))
                LineMark(x: .value("Month", "Apr"), y: .value("Growth", 20))
            }
            .frame(height: 220)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
