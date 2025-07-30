// ===== START FILE: HomepageView.swift =====
// The landing page for the app, with navigation to Workout, Planner, History, Settings, and delete all data.
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
                .buttonStyle(HomeButtonStyle(color: .green))

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
                    .onAppear {
                        workoutManager.loadWorkouts(context: context)
                    }
                }
                .buttonStyle(HomeButtonStyle(color: .blue))

                // Navigation to Workout History
                NavigationLink("Workout History") {
                    WorkoutHistoryPagerView()
                }
                .buttonStyle(HomeButtonStyle(color: .orange))

                // Navigation to Settings
                NavigationLink("Settings") {
                    SettingsView()
                }
                .buttonStyle(HomeButtonStyle(color: .purple))

                // Delete All Data Button
                Button("Delete All Data") {
                    showDeleteAllAlert = true
                }
                .buttonStyle(HomeButtonStyle(color: .red))
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
        // Delete all workouts
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
    }
}

// MARK: - Home Button Style
struct HomeButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

// Wrapper for WorkoutPlannerView
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

// ===== END FILE: HomepageView.swift =====
