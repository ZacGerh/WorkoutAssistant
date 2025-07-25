// ===== START FILE: WorkoutManager.swift (Added replaceAll) =====
import SwiftUI
import SwiftData

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []

    func loadWorkouts(context: ModelContext) {
        let descriptor = FetchDescriptor<Workout>()
        if let fetched = try? context.fetch(descriptor) {
            self.workouts = fetched.sorted { $0.createdAt < $1.createdAt }
        }
    }

    func saveWorkout(_ workout: Workout, context: ModelContext) {
        context.insert(workout)
        try? context.save()
        loadWorkouts(context: context)
    }

    func replaceAll(_ newWorkouts: [Workout], context: ModelContext) {
        // Remove old workouts
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
// ===== END FILE: WorkoutManager.swift (Added replaceAll) =====
