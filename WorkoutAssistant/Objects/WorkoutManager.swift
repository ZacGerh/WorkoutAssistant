// Handles loading, saving, and replacing workout data using SwiftData.
import SwiftUI
import SwiftData

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []

    /// Load workouts from SwiftData and sort by insertion date.
    func loadWorkouts(context: ModelContext) {
        let descriptor = FetchDescriptor<Workout>()
        if let fetched = try? context.fetch(descriptor) {
            self.workouts = fetched.sorted { $0.createdAt < $1.createdAt }
        }
    }

    /// Save a single workout.
    func saveWorkout(_ workout: Workout, context: ModelContext) {
        context.insert(workout)
        try? context.save()
        loadWorkouts(context: context)
    }

    /// Replace all workouts with a new list.
    func replaceAll(_ newWorkouts: [Workout], context: ModelContext) {
        for workout in workouts {
            context.delete(workout)
        }
        for newWorkout in newWorkouts {
            context.insert(newWorkout)
        }
        try? context.save()
        self.workouts = newWorkouts
    }
}
