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
    var customWeights: [CustomWeight]

    init(id: UUID = UUID(),
         name: String = "",
         weight: Double = 0.0,
         incrementWeight: Double = 5.0,
         reps: Int = 10,
         setCount: Int = 3,
         useCustomWeights: Bool = false,
         customWeights: [CustomWeight] = []) {
        self.id = id
        self.name = name
        self.weight = weight
        self.incrementWeight = incrementWeight
        self.reps = reps
        self.setCount = setCount
        self.useCustomWeights = useCustomWeights
        self.customWeights = customWeights
    }
    
    // Custom initializer for converting a Workout to a PlannedWorkout
    init(from workout: Workout) {
        self.id = UUID()
        self.name = workout.name
        self.weight = workout.weight
        self.incrementWeight = workout.incrementWeight
        self.reps = workout.initialReps
        self.setCount = workout.sets.count // or any logic to calculate this
        self.useCustomWeights = workout.useCustomWeights
        self.customWeights = workout.customWeights
            .reduce(into: [Double: Int]()) { counts, weight in
                counts[weight, default: 0] += 1
            }
            .map { CustomWeight(weight: $0.key, count: $0.value) }
    }

    // This is to convert from PlannedWorkout to Workout
    func toWorkout() -> Workout {
        return Workout(
            id: UUID(),
            name: self.name,
            weight: self.weight,
            incrementWeight: self.incrementWeight,
            initialReps: self.reps,
            sets: (0..<setCount).map { _ in WorkoutSet(reps: reps) },
            useCustomWeights: self.useCustomWeights,
            customWeights: self.customWeights.flatMap { Array(repeating: $0.weight, count: $0.count) }
        )
    }
}
