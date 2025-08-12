// ===== START FILE: WorkoutResult.swift =====
import Foundation
import SwiftData

@Model
class WorkoutResult: Identifiable {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var totalTime: Double
    var workouts: [WorkoutResultItem]
    var overallSuccess: Bool

    // NEW: run info (stored in miles)
    var runEnabled: Bool
    var runGoalMiles: Double
    var runTotalMiles: Double

    init(
        id: UUID = UUID(),
        timestamp: Date,
        totalTime: Double,
        workouts: [WorkoutResultItem],
        overallSuccess: Bool,
        runEnabled: Bool = false,
        runGoalMiles: Double = 0,
        runTotalMiles: Double = 0
    ) {
        self.id = id
        self.timestamp = timestamp
        self.totalTime = totalTime
        self.workouts = workouts
        self.overallSuccess = overallSuccess
        self.runEnabled = runEnabled
        self.runGoalMiles = runGoalMiles
        self.runTotalMiles = runTotalMiles
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
// ===== END FILE: WorkoutResult.swift =====
