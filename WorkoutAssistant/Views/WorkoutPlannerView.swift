// --- WorkoutPlannerView.swift ---
import SwiftUI
import SwiftData

struct WorkoutPlannerView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.modelContext) private var context
    @FocusState private var focusedWorkoutID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Workout Planner")
                .font(.largeTitle)
                .bold()

            List {
                ForEach(workoutManager.workouts) { workout in
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Workout Name", text: Binding(
                            get: { workout.name },
                            set: { workout.name = $0; workoutManager.saveWorkout(workout, context: context) }
                        ))
                        .focused($focusedWorkoutID, equals: workout.id)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Starting Weight", value: Binding(
                            get: { workout.weight },
                            set: { workout.weight = $0; workoutManager.saveWorkout(workout, context: context) }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Increment Weight", value: Binding(
                            get: { workout.incrementWeight },
                            set: { workout.incrementWeight = $0; workoutManager.saveWorkout(workout, context: context) }
                        ), format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                        Stepper("Number of Sets: \\(workout.sets.count)", value: Binding(
                            get: { workout.sets.count },
                            set: { newValue in
                                let reps = workout.initialReps
                                workout.sets = Array(repeating: WorkoutSet(reps: reps), count: newValue)
                                workoutManager.saveWorkout(workout, context: context)
                            }
                        ), in: 1...10)

                        Stepper("Reps per Set: \\(workout.initialReps)", value: Binding(
                            get: { workout.initialReps },
                            set: { newReps in
                                workout.initialReps = newReps
                                for i in 0..<workout.sets.count {
                                    workout.sets[i].reps = newReps
                                    workout.sets[i].state = "notStarted"
                                }
                                workoutManager.saveWorkout(workout, context: context)
                            }
                        ), in: 1...20)
                    }
                    .padding(.vertical, 5)
                }
            }

            HStack {
                Button("Add Workout") {
                    let newWorkout = Workout(name: "New Workout", weight: 0, incrementWeight: 5, initialReps: 10, sets: [WorkoutSet(reps: 10)])
                    workoutManager.saveWorkout(newWorkout, context: context)
                    print("Add Workout button pressed")
                    focusedWorkoutID = newWorkout.id
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .onAppear {
            print("WorkoutPlannerView appeared, loading workouts")
            workoutManager.loadWorkouts(context: context)
            if workoutManager.workouts.isEmpty {
                let defaultWorkout = Workout(name: "Bench Press", weight: 45, incrementWeight: 5, initialReps: 10, sets: [WorkoutSet(reps: 10), WorkoutSet(reps: 10), WorkoutSet(reps: 10)])
                workoutManager.saveWorkout(defaultWorkout, context: context)
            }
        }
    }
}
