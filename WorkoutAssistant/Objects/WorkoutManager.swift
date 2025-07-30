import SwiftUI
import SwiftData

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []

    /// Load workouts from SwiftData and sort by insertion date.
    func loadWorkouts(context: ModelContext) {
        let descriptor = FetchDescriptor<Workout>()
        do {
            let fetched = try context.fetch(descriptor)
            self.workouts = fetched.sorted { $0.createdAt < $1.createdAt }
        } catch {
            print("❌ Error loading workouts: \(error)")
        }
    }

    /// Save a single workout.
    func saveWorkout(_ workout: Workout, context: ModelContext) {
        context.insert(workout)
        do {
            try context.save()
            loadWorkouts(context: context)
        } catch {
            print("❌ Error saving workout: \(error)")
        }
    }

    /// Replace all workouts with a new list.
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
        print("⚙️ Adjusting weights based on workout results with thresholds...")

        for result in results {
            guard let workout = workouts.first(where: { $0.id == result.id }) else {
                print("⚠️ No matching workout found for \(result.name)")
                continue
            }

            if result.success {
                workout.consecutiveFailures = 0
                workout.consecutiveSuccesses += 1

                if workout.consecutiveSuccesses >= settings.incrementAfterSuccess {
                    workout.weight += workout.incrementWeight
                    workout.consecutiveSuccesses = 0
                    print("✅ \(workout.name) incremented to \(workout.weight) \(settings.weightUnit.rawValue)")
                }
            } else {
                workout.consecutiveSuccesses = 0
                workout.consecutiveFailures += 1

                if workout.consecutiveFailures >= settings.decrementAfterFailures {
                    if settings.usePercentageForDecrement {
                        workout.weight = roundToTolerance(
                            workout.weight * (settings.decrementPercentage / 100),
                            tolerance: settings.defaultIncrement
                        )
                    } else {
                        workout.weight = max(settings.defaultIncrement, workout.weight - settings.defaultIncrement)
                    }
                    workout.consecutiveFailures = 0
                    print("❌ \(workout.name) decremented to \(workout.weight) \(settings.weightUnit.rawValue)")
                }
            }
        }

        try? context.save()
        loadWorkouts(context: context)
    }

    // MARK: - Rounding Helper
    private func roundToTolerance(_ value: Double, tolerance: Double) -> Double {
        let rounded = ceil(value / tolerance) * tolerance
        return rounded
    }
}
