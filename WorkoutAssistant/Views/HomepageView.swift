// Main landing page with navigation to workouts, planner, and history.

import SwiftUI
import SwiftData

struct HomePageView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.modelContext) private var context
    @State private var showDeleteAllAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Gym Assistant")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // Navigation to Today's Workout
                NavigationLink("Today's Workout") {
                    WorkoutView()
                        .environmentObject(workoutManager)
                }
                .buttonStyleMenu(color: .green)

                // Navigation to Workout Planner
                NavigationLink("Workout Planner") {
                    WorkoutPlannerWrapper(
                        onDismiss: {},
                        existingWorkouts: workoutManager.workouts,
                        onSave: { updatedWorkouts in
                            workoutManager.replaceAll(updatedWorkouts, context: context)
                        }
                    )
                    .environmentObject(workoutManager)
                    .onAppear { workoutManager.loadWorkouts(context: context) }
                }
                .buttonStyleMenu(color: .blue)

                // Navigation to Workout History
                NavigationLink("Workout History") {
                    WorkoutHistoryPagerView()
                }
                .buttonStyleMenu(color: .orange)

                // Delete All Data Button
                Button("Delete All Data") {
                    showDeleteAllAlert = true
                }
                .buttonStyleMenu(color: .red)
            }
            .padding()
            .alert("Delete All Data?",
                   isPresented: $showDeleteAllAlert,
                   actions: {
                       Button("Cancel", role: .cancel) {}
                       Button("Delete", role: .destructive) {
                           deleteAllData()
                       }
                   },
                   message: {
                       Text("This will remove all workouts and workout history permanently.")
                   })
        }
    }

    /// Deletes all Workout and WorkoutResult data from SwiftData.
    private func deleteAllData() {
        for workout in workoutManager.workouts {
            context.delete(workout)
        }

        // Delete all WorkoutResults if they exist
        let resultDescriptor = FetchDescriptor<WorkoutResult>()
        if let results = try? context.fetch(resultDescriptor) {
            for result in results {
                context.delete(result)
            }
        }

        try? context.save()
        workoutManager.workouts.removeAll()
        workoutManager.loadWorkouts(context: context) // Reload after delete
    }
}

// MARK: - Button Style Helper
private extension View {
    func buttonStyleMenu(color: Color) -> some View {
        self.padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

// Wrapper for Planner
struct WorkoutPlannerWrapper: View {
    let onDismiss: () -> Void
    let existingWorkouts: [Workout]
    let onSave: ([Workout]) -> Void

    var body: some View {
        WorkoutPlannerView(
            onSave: { workouts in onSave(workouts) },
            onCancel: { onDismiss() },
            existingWorkouts: existingWorkouts
        )
    }
}
