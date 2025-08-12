import Foundation
import SwiftData

@Model
class WorkoutResult: Identifiable {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var totalTime: Double
    @Relationship(deleteRule: .cascade) var workouts: [WorkoutResultItem]
    var overallSuccess: Bool

    init(
        id: UUID = UUID(),
        timestamp: Date,
        totalTime: Double,
        workouts: [WorkoutResultItem],
        overallSuccess: Bool
    ) {
        self.id = id
        self.timestamp = timestamp
        self.totalTime = totalTime
        self.workouts = workouts
        self.overallSuccess = overallSuccess
    }
}

@Model
class WorkoutResultItem {
    var id: UUID
    var name: String
    var weight: Double
    var success: Bool
    var failedReps: [Int]

    init(
        id: UUID,
        name: String,
        weight: Double,
        success: Bool,
        failedReps: [Int] = []
    ) {
        self.id = id
        self.name = name
        self.weight = weight
        self.success = success
        self.failedReps = failedReps
    }
}
