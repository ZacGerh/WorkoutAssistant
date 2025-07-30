// Models for workouts and sets, designed for SwiftData persistence.
// Includes Workout, WorkoutSet, WorkoutResult, and WorkoutResultItem.

import Foundation
import SwiftData

// MARK: - Workout Model
@Model
class Workout {
    @Attribute(.unique) var id: UUID          // Unique identifier
    var name: String                          // Workout name (e.g., "Bench Press")
    var weight: Double                        // Current weight used for this workout
    var incrementWeight: Double               // Weight increment step
    var initialReps: Int                      // Default reps per set
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet] // Associated sets (cascade on delete)
    var createdAt: Date                       // Used to preserve insertion order

    init(
        id: UUID = UUID(),
        name: String,
        weight: Double,
        incrementWeight: Double,
        initialReps: Int,
        sets: [WorkoutSet],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.weight = weight
        self.incrementWeight = incrementWeight
        self.initialReps = initialReps
        self.sets = sets
        self.createdAt = createdAt
    }
}

// MARK: - WorkoutSet Model
@Model
class WorkoutSet {
    var reps: Int               // Number of reps for this set
    var state: String           // Possible values: "notStarted", "success", "failure"

    init(reps: Int, state: String = "notStarted") {
        self.reps = reps
        self.state = state
    }
}
