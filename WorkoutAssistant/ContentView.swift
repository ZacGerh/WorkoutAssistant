import SwiftUI

// MARK: - ContentView with Navigation
struct ContentView: View {
    @StateObject private var workoutManager = WorkoutManager()

    var body: some View {
        NavigationStack {
            WorkoutView()
                .environmentObject(workoutManager)
                .navigationTitle("Gym Assistant")
                .toolbar {
                    NavigationLink("Planner") {
                        WorkoutPlannerView()
                            .environmentObject(workoutManager)
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
