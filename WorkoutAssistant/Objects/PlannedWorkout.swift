import SwiftUI

// This struct will store the high-level information needed to create the workout
struct PlannedWorkout: Identifiable {
    var id = UUID()
    var name: String
    var weight: Double
    var incrementWeight: Double
    var initialReps: Int
    var setCount: Int
    var useCustomWeights: Bool
    var customWeights: [CustomWeight] // The list of available custom weights

    // Initialize with default values
    init(
        name: String = "New Workout",
        weight: Double = 45.0,
        incrementWeight: Double = 5.0,
        initialReps: Int = 10,
        setCount: Int = 3,
        useCustomWeights: Bool = false,
        customWeights: [CustomWeight] = []
    ) {
        self.name = name
        self.weight = weight
        self.incrementWeight = incrementWeight
        self.initialReps = initialReps
        self.setCount = setCount
        self.useCustomWeights = useCustomWeights
        self.customWeights = customWeights
    }
}
