//
//  Workout.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/23/25.
//

import Foundation

public struct Workout {
    public var name: String
    public var weight: Int
    public var sets: [WorkoutSet]
}

public struct WorkoutSet {
    public var state: SetState
    public var reps: Int
}

