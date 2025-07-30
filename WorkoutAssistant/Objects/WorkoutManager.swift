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

    // MARK: - Adjust Weights After Workout
    func adjustWeightsAfterWorkout(context: ModelContext, results: [WorkoutResultItem], settings: SettingsManager) {
        print("⚙️ Adjusting weights based on workout results...")

        for result in results {
            guard let workout = workouts.first(where: { $0.id == result.id }) else { continue }

            if result.success {
                // Increment logic
                workout.weight += settings.defaultIncrement
                workout.weight = roundToTolerance(workout.weight, tolerance: settings.weightTolerance)
                print("✅ \(workout.name) incremented to \(workout.weight)\(settings.weightUnit.rawValue)")
            } else {
                // Failure logic: decrement based on settings
                if settings.usePercentageForDecrement {
                    workout.weight *= settings.decrementPercentage / 100
                } else {
                    workout.weight -= settings.defaultDecrement
                }
                workout.weight = max(0, roundToTolerance(workout.weight, tolerance: settings.weightTolerance))
                print("❌ \(workout.name) decremented to \(workout.weight)\(settings.weightUnit.rawValue)")
            }
        }

        try? context.save()
        loadWorkouts(context: context)
    }

    // MARK: - Rounding Helper
    private func roundToTolerance(_ value: Double, tolerance: Double) -> Double {
        ceil(value / tolerance) * tolerance
    }
}
