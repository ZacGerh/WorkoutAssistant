import SwiftUI
import SwiftData

struct WorkoutPlannerView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var plannedWorkouts: [PlannedWorkout] = []
    @FocusState private var focusedWorkoutID: UUID?

    var onSave: (([Workout]) -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    var existingWorkouts: [Workout] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Workout Planner")
                .font(.largeTitle)
                .bold()

            List {
                ForEach(plannedWorkouts.indices, id: \.self) { index in
                    WorkoutCardView(plannedWorkout: $plannedWorkouts[index])
                        .padding(.bottom, 10)
                }
            }

            ButtonSectionView(
                addWorkout: addWorkout,
                saveWorkouts: saveWorkouts,
                cancelWorkouts: cancelWorkouts
            )
        }
        .padding()
        .onAppear {
            plannedWorkouts = existingWorkouts.map { workout in
                PlannedWorkout(
                    name: workout.name,
                    weight: workout.weight,
                    incrementWeight: workout.incrementWeight,
                    initialReps: workout.initialReps,
                    setCount: workout.sets.count,
                    useCustomWeights: !workout.customWeights.isEmpty,
                    customWeights: workout.customWeights
                )
            }
        }
    }

    private func addWorkout() {
        let newPlannedWorkout = PlannedWorkout(
            name: "New Workout",
            weight: settings.defaultStartingWeight,
            incrementWeight: settings.defaultIncrement,
            initialReps: settings.defaultReps,
            setCount: settings.defaultSets
        )
        plannedWorkouts.append(newPlannedWorkout)
        focusedWorkoutID = newPlannedWorkout.id
    }

    private func saveWorkouts() {
        // Convert the planned workouts into actual workouts with sets and reps
        let workouts: [Workout] = plannedWorkouts.map { plannedWorkout in
            var sets: [WorkoutSet] = []

            // Create sets based on setCount and initialReps
            for _ in 0..<plannedWorkout.setCount {
                let newSet = WorkoutSet(reps: plannedWorkout.initialReps)
                sets.append(newSet)
            }

            // Create and return the full Workout object
            return Workout(
                id: plannedWorkout.id,
                name: plannedWorkout.name,
                weight: plannedWorkout.weight,
                incrementWeight: plannedWorkout.incrementWeight,
                initialReps: plannedWorkout.initialReps,
                sets: sets
            )
        }
        onSave?(workouts)  // Call the onSave callback to save the actual workouts
        dismiss()
    }


    private func cancelWorkouts() {
        onCancel?()
        dismiss()
    }
}
