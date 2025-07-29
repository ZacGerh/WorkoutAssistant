// Handles loading, saving, and replacing workout data using SwiftData.

import SwiftUI
import SwiftData

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []

    // MARK: - Load Workouts
    func loadWorkouts(context: ModelContext) {
        let descriptor = FetchDescriptor<Workout>()
        do {
            let fetched = try context.fetch(descriptor)
            self.workouts = fetched.sorted { $0.createdAt < $1.createdAt }
        } catch {
            print("❌ Error loading workouts: \(error)")
        }
    }

    // MARK: - Save a Workout
    func saveWorkout(_ workout: Workout, context: ModelContext) {
        context.insert(workout)
        do {
            try context.save()
            loadWorkouts(context: context)
        } catch {
            print("❌ Error saving workout: \(error)")
        }
    }

    // MARK: - Replace All Workouts
    func replaceAll(_ newWorkouts: [Workout], context: ModelContext) {
        for workout in workouts {
            context.delete(workout)
        }
        for newWorkout in newWorkouts {
            context.insert(newWorkout)
        }
        do {
            try context.save()
            self.workouts = newWorkouts
        } catch {
            print("❌ Error replacing workouts: \(error)")
        }
    }
}
