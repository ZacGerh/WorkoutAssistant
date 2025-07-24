// WorkoutPlannerView.swift
import SwiftUI

struct WorkoutPlannerView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss

    @FocusState private var focusedWorkoutID: UUID?
    @State private var originalWorkouts: [Workout] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Workout Planner")
                .font(.largeTitle)
                .bold()

            List {
                ForEach($workoutManager.workouts) { $workout in
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Workout Name", text: $workout.name)
                            .focused($focusedWorkoutID, equals: workout.id)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Starting Weight", value: $workout.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Increment Weight", value: $workout.incrementWeight, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Stepper("Number of Sets: \(workout.sets.count)", value: Binding(
                            get: { workout.sets.count },
                            set: { newValue in
                                let initialReps = workout.initialReps
                                workout.sets = Array(repeating: .notStarted(initialReps), count: newValue)
                            }
                        ), in: 1...10)

                        Stepper("Reps per Set: \(workout.initialReps)", value: $workout.initialReps, in: 1...20)
                            .onChange(of: workout.initialReps) { _, newReps in
                                for i in 0..<workout.sets.count {
                                    workout.sets[i] = .notStarted(newReps)
                                }
                            }
                    }
                    .padding(.vertical, 5)
                }
            }

            HStack(spacing: 15) {
                Button(action: addWorkout) {
                    Text("Add Workout")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: saveAndExit) {
                    Text("Save")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .onAppear {
            workoutManager.loadWorkouts()
            originalWorkouts = workoutManager.workouts
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    workoutManager.workouts = originalWorkouts
                    dismiss()
                }
            }
        }
    }

    private func addWorkout() {
        let newWorkout = Workout(name: "", weight: 0, incrementWeight: 0, initialReps: 10, sets: [.notStarted(10)])
        workoutManager.workouts.append(newWorkout)
        focusedWorkoutID = newWorkout.id
    }

    private func saveAndExit() {
        workoutManager.saveWorkouts()
        dismiss()
    }
}
