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
                        let newSets = (0..<numberOfSets).map { _ in
                            WorkoutSet(state: SetState.notStarted(repsPerSet), reps: repsPerSet)
                        }

                        let newWorkout = Workout(name: workoutName, weight: weight, sets: newSets)
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

#Preview {
    @State var workouts: [Workout] = [
        Workout(name: "Chest Press", weight: 45, sets: [
            WorkoutSet(state: .notStarted(10), reps: 10),
            WorkoutSet(state: .notStarted(10), reps: 10),
            WorkoutSet(state: .notStarted(10), reps: 10)
        ]),
        Workout(name: "This Is A Really Long Name", weight: 50, sets: [
            WorkoutSet(state: .notStarted(8), reps: 8),
            WorkoutSet(state: .notStarted(7), reps: 7),
            WorkoutSet(state: .notStarted(6), reps: 6)
        ]),
        Workout(name: "5 by 5", weight: 55, sets: [
            WorkoutSet(state: .notStarted(5), reps: 5),
            WorkoutSet(state: .notStarted(5), reps: 5),
            WorkoutSet(state: .notStarted(5), reps: 5),
            WorkoutSet(state: .notStarted(5), reps: 5),
            WorkoutSet(state: .notStarted(5), reps: 5)
        ]),

    ]
    AddWorkoutView(workouts: $workouts)
}
