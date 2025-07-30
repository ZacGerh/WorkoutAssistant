//
//  WorkoutDetailHistoryPage.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/29/25.
//


import SwiftUI
import SwiftData

struct WorkoutDetailHistoryPage: View {
    let results: [WorkoutResult]
    let workoutName: String

    var body: some View {
        List {
            let filteredResults = results.filter { result in
                result.workouts.contains(where: { $0.name == workoutName })
            }

            if filteredResults.isEmpty {
                Text("No history found for \(workoutName).")
                    .foregroundColor(.gray)
            } else {
                ForEach(filteredResults) { result in
                    if let workoutItem = result.workouts.first(where: { $0.name == workoutName }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.timestamp, style: .date)
                                .font(.headline)
                            Text("Weight: \(Int(workoutItem.weight)) lbs")
                            Text("Result: \(workoutItem.success ? "Success" : "Failure")")
                                .foregroundColor(workoutItem.success ? .green : .red)
                            if !workoutItem.success, !workoutItem.failedReps.isEmpty {
                                Text("Failed Reps: \(workoutItem.failedReps.map(String.init).joined(separator: ", "))")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .navigationTitle(workoutName)
    }
}
