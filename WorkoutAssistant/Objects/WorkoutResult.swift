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

    // Run info (label-only units; we store the number you enter)
    var runEnabled: Bool
    var runGoalMiles: Double   // naming kept for backward compat; treated as a plain number
    var runTotalMiles: Double  // naming kept for backward compat; treated as a plain number

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

    // NEW: snapshot so totals don’t drift if plan changes later
    var totalSetsAtTime: Int
    var repsAtTime: Int

    init(
        id: UUID,
        name: String,
        weight: Double,
        success: Bool,
        failedReps: [Int] = [],
        totalSetsAtTime: Int = 0,
        repsAtTime: Int = 0
    ) {
        self.id = id
        self.name = name
        self.weight = weight
        self.success = success
        self.failedReps = failedReps
        self.totalSetsAtTime = totalSetsAtTime
        self.repsAtTime = repsAtTime
    }
}
// ===== END FILE: WorkoutResult.swift =====
