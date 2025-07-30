//
//  WorkoutHistoryOverviewPage.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/29/25.
//


import SwiftUI
import SwiftData

struct WorkoutHistoryOverviewPage: View {
    let results: [WorkoutResult]

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
    }

    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds / 60)
        let remaining = Int(seconds.truncatingRemainder(dividingBy: 60))
        return "\(minutes)m \(remaining)s"
    }
}
