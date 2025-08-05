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
                var newWeight = workout.weight + settings.defaultIncrement
                
                // Check if the incremented weight is valid
                if workout.useCustomWeights {
                    newWeight = findClosestValidWeight(oldWeight: workout.weight, targetWeight: newWeight, availableWeights: workout.customWeights, increment: result.success)
                    
                } else {
                    newWeight = roundToTolerance(newWeight, tolerance: settings.weightTolerance)
                }
                workout.weight = newWeight
                print("✅ \(workout.name) incremented to \(workout.weight)\(settings.weightUnit.rawValue)")
            } else {
                var newWeight = workout.weight
                // Failure logic: decrement based on settings
                if settings.usePercentageForDecrement {
                    newWeight *= settings.decrementPercentage / 100
                } else {
                    newWeight -= settings.defaultDecrement
                }
                if workout.useCustomWeights {
                    newWeight = findClosestValidWeight(oldWeight: workout.weight, targetWeight: newWeight, availableWeights: workout.customWeights, increment: result.success)
                } else {
                    newWeight = max(0, roundToTolerance(newWeight, tolerance: settings.weightTolerance))
                }
                workout.weight = newWeight
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

private func findClosestValidWeight(oldWeight: Double, targetWeight: Double, availableWeights: [Double], increment : Bool) -> Double {
    
    let sortedWeights = availableWeights.sorted { $0 > $1 }
    let closestWeight = sortedWeights.last(where: { $0 >= targetWeight }) ?? 0
    if(closestWeight == targetWeight){
        return targetWeight
    }
    else{
        let newWeight = findClosestValidWeightRecursive(targetWeight: targetWeight, availableWeights: sortedWeights)
        if increment && (newWeight == oldWeight || abs(newWeight-oldWeight) > abs(closestWeight-oldWeight)) {
            return closestWeight
        }
        return newWeight
    }
}

private func findClosestValidWeightRecursive(targetWeight: Double, availableWeights: [Double]) -> Double {
    
    let weight = availableWeights.first ?? 0
    if weight == targetWeight || availableWeights.count <= 1 {
        return weight
    }
    
    if weight < targetWeight {
        // Recursive call to reduce the target weight by the current weight
        let remainingWeight = targetWeight - weight
        return weight + findClosestValidWeightRecursive(targetWeight: remainingWeight, availableWeights: Array(availableWeights.dropFirst()))
    }

    return findClosestValidWeightRecursive(targetWeight: targetWeight, availableWeights: Array(availableWeights.dropFirst()))
}
