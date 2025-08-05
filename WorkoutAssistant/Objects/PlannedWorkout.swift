import SwiftUI
import SwiftData

struct PlannedWorkout: Identifiable {
    let id: UUID
    var name: String
    var weight: Double
    var incrementWeight: Double
    var reps: Int
    var setCount: Int
    var useCustomWeights: Bool
    var customWeights: [WeightCount]    // ← changed

    init(id: UUID = UUID(),
         name: String = "",
         weight: Double = 0.0,
         incrementWeight: Double = 5.0,
         reps: Int = 10,
         setCount: Int = 3,
         useCustomWeights: Bool = false,
         customWeights: [WeightCount] = []) {
        self.id = id
        self.name = name
        self.weight = weight
        self.incrementWeight = incrementWeight
        self.reps = reps
        self.setCount = setCount
        self.useCustomWeights = useCustomWeights
        self.customWeights = customWeights
    }

    // Converts a persisted Workout into a draft PlannedWorkout
    init(from workout: Workout) {
        self.id = workout.id
        self.name = workout.name
        self.weight = workout.weight
        self.incrementWeight = workout.incrementWeight
        self.reps = workout.initialReps
        self.setCount = workout.sets.count
        self.useCustomWeights = workout.useCustomWeights
        // map each plate-count into WeightCount
        let counts = workout.customWeights.reduce(into: [Double:Int]()) { acc, w in
            acc[w, default: 0] += 1
        }
        self.customWeights = counts.map { WeightCount(weight: $0.key, count: $0.value) }
    }

    // Converts draft back into a persistent Workout
    func toWorkout() -> Workout {
        Workout(
            id: UUID(),
            name: name,
            weight: weight,
            incrementWeight: incrementWeight,
            initialReps: reps,
            sets: (0..<setCount).map { _ in WorkoutSet(reps: reps) },
            useCustomWeights: useCustomWeights,
            // flatten to [Double]
            customWeights: customWeights.flatMap { Array(repeating: $0.weight, count: $0.count) }
        )
    }
}
