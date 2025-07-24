// Workout.swift (SwiftData Model)
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

    init(id: UUID = UUID(), name: String, weight: Double, incrementWeight: Double, initialReps: Int, sets: [WorkoutSet]) {
        self.id = id
        self.name = name
        self.weight = weight
        self.incrementWeight = incrementWeight
        self.initialReps = initialReps
        self.sets = sets
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
