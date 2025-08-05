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
        customWeights: [Double] = []
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
