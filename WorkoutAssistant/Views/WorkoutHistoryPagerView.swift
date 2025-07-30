//
//  WorkoutHistoryPagerView.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/29/25.
//


import SwiftUI
import SwiftData

struct WorkoutHistoryPagerView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutResult.timestamp, order: .reverse) private var results: [WorkoutResult]
    
    private var uniqueWorkoutNames: [String] {
        let allNames = results.flatMap { $0.workouts.map { $0.name } }
        return Array(Set(allNames)).sorted()
    }

    var body: some View {
        TabView {
            // Page 0: Overview
            WorkoutHistoryOverviewPage(results: results)
                .tag(0)

            // Pages 1..N: Each unique workout
            ForEach(uniqueWorkoutNames, id: \.self) { workoutName in
                WorkoutDetailHistoryPage(results: results, workoutName: workoutName)
                    .tag(workoutName)
            }
        }
        .tabViewStyle(.page)
        .navigationTitle("Workout History")
    }
}
