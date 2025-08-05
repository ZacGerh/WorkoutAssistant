import SwiftUI
import SwiftData



struct WorkoutPlannerView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var tempWorkouts: [PlannedWorkout] = []
    
    var onSave: (([Workout]) -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    var existingWorkouts: [Workout] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Workout Planner")
                .font(.largeTitle)
                .bold()

            List {
                ForEach(tempWorkouts.indices, id: \.self) { index in
                    WorkoutCardView(plannedWorkout: $tempWorkouts[index])
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
            // First load from SwiftData…
            workoutManager.loadWorkouts(context: context)
            // …then map the freshly loaded workouts into your draft array
            tempWorkouts = workoutManager.workouts.map { PlannedWorkout(from: $0) }
        }
    }

    private func addWorkout() {
        let newWorkout = PlannedWorkout(
            name: "New Workout",
            weight: settings.defaultStartingWeight,
            incrementWeight: settings.defaultIncrement,
            reps: settings.defaultReps,
            setCount: settings.defaultSets
        )
        tempWorkouts.append(newWorkout)
    }

    private func saveWorkouts() {
        let workouts = tempWorkouts.map { $0.toWorkout() }
        onSave?(workouts) // Pass the new workouts to the save handler
        dismiss()
    }

    private func cancelWorkouts() {
        onCancel?()
        dismiss()
    }
}
