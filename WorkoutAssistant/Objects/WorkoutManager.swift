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
            var newWeight = workout.weight
            if result.success {
                newWeight += workout.incrementWeight
                
            } else {
                // Failure logic: decrement based on settings
                if settings.usePercentageForDecrement {
                    newWeight *= settings.decrementPercentage / 100
                } else {
                    newWeight -= settings.defaultDecrement
                }
            }
            
            if workout.useCustomWeights {
                if result.success {
                    newWeight = nextHigherWeight(current: newWeight, available: workout.customWeights)
                } else {
                    newWeight = nextLowerWeight(current: newWeight, available: workout.customWeights)
                }
            } else {
                newWeight = roundToTolerance(newWeight, tolerance: settings.weightTolerance)
            }
            workout.weight = newWeight

        }

        try? context.save()
        loadWorkouts(context: context)
    }

    // MARK: - Rounding Helper
    private func roundToTolerance(_ value: Double, tolerance: Double) -> Double {
        ceil(value / tolerance) * tolerance
    }
}

// MARK: – Plate combinatorics
private func allCombinationWeights(from available: [Double]) -> [Double] {
    var sums: Set<Double> = [0]
    for plate in available {
        let newSums = sums.map { $0 + plate }
        sums.formUnion(newSums)
    }
    sums.remove(0)              // drop the 0lb option
    return Array(sums).sorted() // ascending
}

/// Smallest valid weight strictly > current
private func nextHigherWeight(current: Double, available: [Double]) -> Double {
    allCombinationWeights(from: available).first { $0 >= current } ?? current
}

/// Largest valid weight strictly < current
private func nextLowerWeight(current: Double, available: [Double]) -> Double {
    allCombinationWeights(from: available).last { $0 <= current } ?? current
}

