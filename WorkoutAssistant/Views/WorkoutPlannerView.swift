//
//  WorkoutPlannerView.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/23/25.
//

import SwiftUI

struct WorkoutPlannerView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Workout Planner")
                .font(.largeTitle)
                .bold()

            List {
                ForEach($workoutManager.workouts) { $workout in
                    VStack(alignment: .leading) {
                        TextField("Workout Name", text: $workout.name)
                        HStack {
                            Stepper("Weight: \(workout.weight) lbs", value: $workout.weight, in: 0...500, step: 5)
                        }
                    }
                }
            }

            Button(action: addWorkout) {
                Text("Add Workout")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }

    private func addWorkout() {
        workoutManager.workouts.append(
            Workout(name: "New Workout", weight: 0, reps: 0, sets: [.notStarted(0)])
        )
    }
}
