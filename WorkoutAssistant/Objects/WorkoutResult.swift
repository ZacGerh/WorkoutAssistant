// Stores historical results of completed workouts.

import Foundation
import SwiftData

@Model
class WorkoutResult {
    var timestamp: Date               // When the workout occurred
    var totalTime: Double             // Total workout time (in seconds)
    var workouts: [WorkoutResultItem] // Details of each exercise performed
    var overallSuccess: Bool          // Whether all sets were successful

    init(
        timestamp: Date,
        totalTime: Double,
        workouts: [WorkoutResultItem],
        overallSuccess: Bool
    ) {
        self.timestamp = timestamp
        self.totalTime = totalTime
        self.workouts = workouts
        self.overallSuccess = overallSuccess
    }
}

@Model
class WorkoutResultItem {
    var id: UUID                      // ID of the associated Workout
    var name: String                  // Workout name
    var weight: Double                // Weight used during workout
    var success: Bool                 // Whether this workout succeeded
    var failedReps: [Int]             // List of reps for failed sets

    init(id: UUID, name: String, weight: Double, success: Bool, failedReps: [Int] = []) {
        self.id = id
        self.name = name
        self.weight = weight
        self.success = success
        self.failedReps = failedReps
    }
}
