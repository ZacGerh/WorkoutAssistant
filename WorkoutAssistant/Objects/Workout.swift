// Workout.swift (SwiftData Model with timestamp)
import Foundation
import SwiftData

@Model
class Workout {
    @Attribute(.unique) var id: UUID
    var name: String
    var weight: Double
    var incrementWeight: Double
    var initialReps: Int
    var sets: [WorkoutSet]
    var createdAt: Date // New property for insertion order

    init(id: UUID = UUID(), name: String, weight: Double, incrementWeight: Double, initialReps: Int, sets: [WorkoutSet], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.weight = weight
        self.incrementWeight = incrementWeight
        self.initialReps = initialReps
        self.sets = sets
        self.createdAt = createdAt
    }
}

@Model
class WorkoutSet {
    var reps: Int
    var state: String // notStarted, success, failure

    init(reps: Int, state: String = "notStarted") {
        self.reps = reps
        self.state = state
    }
}
