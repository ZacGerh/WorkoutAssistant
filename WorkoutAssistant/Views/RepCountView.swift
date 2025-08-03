//
//  RepCountView.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 8/3/25.
//


import SwiftUI

struct RepCountView: View {
    @Binding var workout: Workout

    var body: some View {
        HStack {
            Text("Rep Count")
                .frame(width: 120, alignment: .leading)
            Stepper(value: $workout.initialReps, in: 1...20) {
                Text("\(workout.initialReps)")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
