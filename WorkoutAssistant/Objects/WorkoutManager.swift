// ===== START FILE: WorkoutManager.swift =====
// WorkoutManager.swift (SwiftData-compliant with detailed debug)
import Foundation
import SwiftData
import SwiftUI

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []

    init() {
        print("WorkoutManager initialized")
    }

    // Load all workouts from SwiftData
    func loadWorkouts(context: ModelContext) {
        print("Attempting to load workouts...")
        let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\.name)])
        do {
            let fetched = try context.fetch(descriptor)
            DispatchQueue.main.async {
                self.workouts = fetched
                print("Loaded Workouts Count: \(fetched.count)")
                for (index, w) in fetched.enumerated() {
                    print("  [\(index)] Workout: id=\(w.id), name=\(w.name), weight=\(w.weight), sets=\(w.sets.count)")
                }
            }
        } catch {
            print("Error fetching workouts: \(error)")
            self.workouts = []
        }
    }

    // Save or insert a workout
    func saveWorkout(_ workout: Workout, context: ModelContext) {
        print("Attempting to save workout: name=\(workout.name), id=\(workout.id)")
        do {
            context.insert(workout)
            try context.save()
            print("Saved Workout: \(workout.name) with id=\(workout.id)")
            loadWorkouts(context: context)
        } catch {
            print("Error saving workout: \(error)")
        }
    }

    // Delete a workout
    func deleteWorkout(_ workout: Workout, context: ModelContext) {
        print("Attempting to delete workout: \(workout.name), id=\(workout.id)")
        context.delete(workout)
        do {
            try context.save()
            print("Deleted Workout: \(workout.name)")
            loadWorkouts(context: context)
        } catch {
            print("Error deleting workout: \(error)")
        }
    }
}
// ===== END FILE: WorkoutManager.swift =====
