// ===== START FILE: AppPage.swift =====
import Foundation

// Define the AppPage enum used for navigation in HomePageView
enum AppPage: Identifiable {
    case home
    case workout
    case planner(fromWorkout: Bool)
    
    var id: String {
        switch self {
        case .home: return "home"
        case .workout: return "workout"
        case .planner(let fromWorkout): return "planner-\(fromWorkout)"
        }
    }
}
// ===== END FILE: AppPage.swift =====
