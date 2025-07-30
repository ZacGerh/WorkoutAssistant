import SwiftUI
import SwiftData
import Charts

struct WorkoutHistoryOverviewPage: View {
    let results: [WorkoutResult]

    var body: some View {
        VStack {
            if results.isEmpty {
                Text("No workout history found.")
                    .foregroundColor(.gray)
            } else {
                // Chart
                Chart(results) { result in
                    BarMark(
                        x: .value("Date", result.timestamp),
                        y: .value("Success", result.overallSuccess ? 1 : 0)
                    )
                    .foregroundStyle(result.overallSuccess ? .green : .red)
                }
                .frame(height: 200)
                .padding()

                // List of results
                List {
                    ForEach(results) { result in
                        VStack(alignment: .leading) {
                            Text(result.timestamp, style: .date)
                                .font(.headline)
                            Text("Duration: \(formatTime(result.totalTime))")
                            Text("Overall Result: \(result.overallSuccess ? "Success" : "Failure")")
                                .foregroundColor(result.overallSuccess ? .green : .red)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds / 60)
        let remaining = Int(seconds.truncatingRemainder(dividingBy: 60))
        return "\(minutes)m \(remaining)s"
    }
}
