import Foundation
import SwiftData

@Model
class Workout {
    @Attribute(.unique) var id: UUID
    var name: String
    var weight: Double
    var incrementWeight: Double
    var initialReps: Int
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet]
    var customWeights: [Double]

    var createdAt: Date
    var consecutiveSuccesses: Int
    var consecutiveFailures: Int
    var useCustomWeights: Bool
    var setCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        weight: Double,
        incrementWeight: Double,
        initialReps: Int,
        sets: [WorkoutSet],
        createdAt: Date = Date(),
        consecutiveSuccesses: Int = 0,
        consecutiveFailures: Int = 0,
        useCustomWeights: Bool = false,
        customWeights: [Double] = [],
        setCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.weight = weight
        self.incrementWeight = incrementWeight
        self.initialReps = initialReps
        self.sets = sets
        self.createdAt = createdAt
        self.consecutiveSuccesses = consecutiveSuccesses
        self.consecutiveFailures = consecutiveFailures
        self.useCustomWeights = useCustomWeights
        self.customWeights = customWeights
        self.setCount = setCount
    }
}

@Model
class CustomWeight: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var weight: Double
    var count: Int

    init(id: UUID = UUID(), weight: Double, count: Int) {
        self.id = id
        self.weight = weight
        self.count = count
    }
}

@Model
class WorkoutSet {
    var reps: Int
    var state: String // "notStarted", "success", "failure"

    init(reps: Int, state: String = "notStarted") {
        self.reps = reps
        self.state = state
    }
}
