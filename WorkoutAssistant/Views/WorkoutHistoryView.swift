// Displays the saved workout history.
import SwiftUI
import SwiftData
import Charts


struct WorkoutHistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutResult.timestamp, order: .reverse) private var results: [WorkoutResult]

    var body: some View {
        List {
            if results.isEmpty {
                Text("No workout history found.")
                    .foregroundColor(.gray)
            } else {
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
        .navigationTitle("Workout History")
        .onAppear {
            print("Loaded \(results.count) workout results from SwiftData.")
        }
    }
    


    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds / 60)
        let remaining = Int(seconds.truncatingRemainder(dividingBy: 60))
        return "\(minutes)m \(remaining)s"
    }

}
