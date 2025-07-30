import Foundation
import SwiftData

// MARK: - Workout Model
@Model
class Workout {
    @Attribute(.unique) var id: UUID
    var name: String
    var weight: Double
    var incrementWeight: Double
    var initialReps: Int
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet]
    var createdAt: Date

    // New fields for thresholds
    var consecutiveSuccesses: Int
    var consecutiveFailures: Int

    init(
        id: UUID = UUID(),
        name: String,
        weight: Double,
        incrementWeight: Double,
        initialReps: Int,
        sets: [WorkoutSet],
        createdAt: Date = Date(),
        consecutiveSuccesses: Int = 0,
        consecutiveFailures: Int = 0
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
    }
}

// MARK: - WorkoutSet Model
@Model
class WorkoutSet {
    var reps: Int
    var state: String // "notStarted", "success", "failure"

    init(reps: Int, state: String = "notStarted") {
        self.reps = reps
        self.state = state
    }
}
