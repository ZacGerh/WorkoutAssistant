//
//  SetCountView.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 8/3/25.
//


import SwiftUI

struct SetCountView: View {
    @Binding var workout: Workout

    var body: some View {
        HStack {
            Text("Set Count")
                .frame(width: 120, alignment: .leading)
            Stepper(value: $workout.setCount, in: 1...10) {
                Text("\(workout.setCount)")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
