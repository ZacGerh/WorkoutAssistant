//
//  AddWorkoutView.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/23/25.
//

import SwiftUI

struct AddWorkoutView: View {
    @Binding var workouts: [Workout]
    @Environment(\.dismiss) var dismiss

    @State private var workoutName: String = ""
    @State private var weight: Int = 0
    @State private var numberOfSets: Int = 5
    @State private var repsPerSet: Int = 10

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $workoutName)
                    Stepper("Weight: \(weight) lbs", value: $weight, in: 0...1000, step: 5)
                }

                Section(header: Text("Sets")) {
                    Stepper("Number of Sets: \(numberOfSets)", value: $numberOfSets, in: 1...10)
                    Stepper("Reps per Set: \(repsPerSet)", value: $repsPerSet, in: 1...20)
                }

                Section {
                    Button("Add Workout") {
                        let newWorkout = Workout(name: workoutName, weight: weight, reps:0, sets: [])
                        workouts.append(newWorkout)
                        dismiss()
                    }
                    .disabled(workoutName.isEmpty)
                }
            }
            .navigationTitle("New Workout")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
}
