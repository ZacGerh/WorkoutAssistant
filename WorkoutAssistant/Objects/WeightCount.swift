//
//  WeightCount.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 8/5/25.
//


import Foundation

/// UI-only representation of a plate + count
struct WeightCount: Identifiable {
    let id = UUID()
    var weight: Double
    var count: Int
}
