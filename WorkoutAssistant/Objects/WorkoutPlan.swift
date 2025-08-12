// ===== START FILE: WorkoutPlan.swift =====
import Foundation
import SwiftData

@Model
final class WorkoutPlan {
    @Attribute(.unique) var id: UUID
    var includeRunSection: Bool
    var runGoalDistance: Double
    var defaultLapDistance: Double

    init(
        id: UUID = UUID(),
        includeRunSection: Bool = false,
        runGoalDistance: Double = 3.0,
        defaultLapDistance: Double = 1.0
    ) {
        self.id = id
        self.includeRunSection = includeRunSection
        self.runGoalDistance = runGoalDistance
        self.defaultLapDistance = defaultLapDistance
    }
}
// ===== END FILE: WorkoutPlan.swift =====
