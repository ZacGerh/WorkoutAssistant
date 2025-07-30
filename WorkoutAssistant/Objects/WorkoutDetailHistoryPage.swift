// Displays detailed history for a specific workout with weight over time.

import SwiftUI
import SwiftData
import Charts

struct WorkoutDetailHistoryPage: View {
    let results: [WorkoutResult]
    let workoutName: String

    /// Filtered results for this workout.
    private var filteredResults: [WorkoutResultItemData] {
        results.compactMap { result in
            guard let workout = result.workouts.first(where: { $0.name == workoutName }) else { return nil }
            return WorkoutResultItemData(timestamp: result.timestamp, weight: workout.weight, success: workout.success)
        }
    }

    var body: some View {
        VStack {
            if filteredResults.isEmpty {
                Text("No history found for \(workoutName).")
                    .foregroundColor(.gray)
            } else {
                // Chart: Weight by Date with markers
                Chart(filteredResults) { item in
                    LineMark(
                        x: .value("Date", item.timestamp),
                        y: .value("Weight", item.weight)
                    )
                    .symbol(.circle)
                    .foregroundStyle(item.success ? .green : .red)
                    .annotation(position: .top) {
                        Text("\(Int(item.weight))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 200)
                .padding()

                // List of results
                List {
                    ForEach(filteredResults) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formatDate(item.timestamp))
                                .font(.headline)
                            Text("Weight: \(Int(item.weight)) lbs")
                            Text("Result: \(item.success ? "Success" : "Failure")")
                                .foregroundColor(item.success ? .green : .red)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .navigationTitle(workoutName)
    }

    /// Formats a Date for display.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Identifiable wrapper for chart data
struct WorkoutResultItemData: Identifiable {
    var id: String { "\(timestamp.timeIntervalSince1970)-\(weight)" }
    let timestamp: Date
    let weight: Double
    let success: Bool
}
