// HomePageView.swift (Update environment)
import SwiftUI

enum AppPage: Identifiable {
    case home
    case workout
    case planner(fromWorkout: Bool)
    
    var id: String {
        switch self {
        case .home: return "home"
        case .workout: return "workout"
        case .planner(let fromWorkout): return "planner-\\(fromWorkout)"
        }
    }
}

struct HomePageView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.modelContext) private var context
    @State private var currentPage: AppPage? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Gym Assistant")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            Button("Today's Workout") {
                workoutManager.loadWorkouts(context: context)
                currentPage = .workout
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Workout Planner") {
                workoutManager.loadWorkouts(context: context)
                currentPage = .planner(fromWorkout: false)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .fullScreenCover(item: $currentPage) { page in
            switch page {
            case .workout:
                WorkoutView(onFinish: { currentPage = nil }, openPlanner: {
                    currentPage = .planner(fromWorkout: true)
                })
                .environmentObject(workoutManager)
            case .planner(let fromWorkout):
                WorkoutPlannerWrapper(onBack: {
                    currentPage = fromWorkout ? .workout : nil
                })
                .environmentObject(workoutManager)
            case .home:
                EmptyView()
            }
        }
    }
}

struct WorkoutPlannerWrapper: View {
    let onBack: () -> Void

    var body: some View {
        NavigationView {
            WorkoutPlannerView()
                .navigationBarItems(leading: Button("Back") {
                    onBack()
                })
        }
    }
}
