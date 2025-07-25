// The landing page for the app, with navigation to Workout and Planner pages.
import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome to Gym Assistant")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                NavigationLink("Today's Workout") {
                    WorkoutView()
                        .environmentObject(workoutManager)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

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
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}

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
