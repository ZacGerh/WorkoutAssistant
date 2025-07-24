//
//  WorkoutManager.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/24/25.
//

// WorkoutManager.swift
import Foundation
import SwiftUI

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []

    private static let workoutsKey = "SavedWorkouts"

    init() {
        loadWorkouts()
    }

    func saveWorkouts() {
        if let data = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(data, forKey: Self.workoutsKey)
        }
    }

    func loadWorkouts() {
        if let data = UserDefaults.standard.data(forKey: Self.workoutsKey),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            workouts = decoded
        } else {
            // Default workouts for first launch
            workouts = [
                Workout(name: "Bench Press", weight: 45, incrementWeight: 5, initialReps: 10, sets: [.notStarted(10), .notStarted(10), .notStarted(10)])
            ]
        }
    }
}
