//
//  Workout.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/23/25.
//

import Foundation

// MARK: - Data Models
struct Workout: Identifiable {
    let id = UUID()
    var name: String
    var weight: Int
    var reps: Int
    var sets: [SetButton.SetState]
}

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = [
        .init(name: "Bench Press", weight: 45, reps: 10, sets: [.notStarted(10), .notStarted(10), .notStarted(10)]),
        .init(name: "Lateral Raise", weight: 25, reps: 8, sets: [.notStarted(8), .notStarted(8)]),
        .init(name: "5x5", weight: 55, reps: 5, sets: [.notStarted(5), .notStarted(5), .notStarted(5), .notStarted(5), .notStarted(5)]),
    ]
}
