import SwiftUI
import SwiftData
import Charts

struct WorkoutHistoryPagerView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutResult.timestamp, order: .reverse) private var results: [WorkoutResult]

    // Selection for TabView
    enum HistoryTab: Hashable {
        case overview
        case workout(String) // workoutName
    }

    @State private var selection: HistoryTab = .overview

    // Alerts managed in parent
    @State private var confirmClearAll = false
    @State private var confirmDeleteAllForWorkout = false

    private var uniqueWorkoutNames: [String] {
        let allNames = results.flatMap { $0.workouts.map { $0.name } }
        return Array(Set(allNames)).sorted()
    }

    private var selectedWorkoutName: String? {
        if case .workout(let name) = selection { return name }
        return nil
    }

    var body: some View {
        TabView(selection: $selection) {
            // Page 0: Overview
            WorkoutHistoryOverviewPage(results: results)
                .tag(HistoryTab.overview)

            // Pages 1..N: Each unique workout
            ForEach(uniqueWorkoutNames, id: \.self) { workoutName in
                WorkoutDetailHistoryPage(results: results, workoutName: workoutName)
                    .tag(HistoryTab.workout(workoutName))
            }
        }
        .tabViewStyle(.page)
        .navigationTitle("Workout History")
        // Single, centralized toolbar (prevents duplicates)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !results.isEmpty {
                    Button(role: .destructive) {
                        if selectedWorkoutName == nil {
                            // Overview page -> clear ALL sessions
                            confirmClearAll = true
                        } else {
                            // Detail page -> clear ALL entries for that workout
                            confirmDeleteAllForWorkout = true
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel(selectedWorkoutName == nil ? "Delete all history" : "Delete all entries for this workout")
                }
            }
        }
        // Confirm clear ALL
        .alert("Delete all history?", isPresented: $confirmClearAll) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                clearAllHistory()
                selection = .overview
            }
        } message: {
            Text("This will remove every saved workout session.")
        }
        // Confirm clear ALL for selected workout
        .alert(deleteAllTitle(), isPresented: $confirmDeleteAllForWorkout) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let name = selectedWorkoutName {
                    deleteAllEntries(for: name)
                }
                selection = .overview
            }
        } message: {
            Text(deleteAllMessage())
        }
    }

    private func deleteAllTitle() -> String {
        if let name = selectedWorkoutName { return "Delete all '\(name)' entries?" }
        return "Delete all entries?"
    }

    private func deleteAllMessage() -> String {
        if let name = selectedWorkoutName {
            return "This removes every recorded set of \(name) from your history. Sessions that only contained this workout will also be removed."
        }
        return "This will remove every saved workout session."
    }

    private func clearAllHistory() {
        let descriptor = FetchDescriptor<WorkoutResult>()
        if let all = try? context.fetch(descriptor) {
            for r in all {
                for item in r.workouts { context.delete(item) }
                context.delete(r)
            }
            try? context.save()
        }
    }

    private func deleteAllEntries(for workoutName: String) {
        let descriptor = FetchDescriptor<WorkoutResult>()
        guard let all = try? context.fetch(descriptor) else { return }

        for result in all {
            let toRemove = result.workouts.filter { $0.name == workoutName }
            for item in toRemove { context.delete(item) }
            result.workouts.removeAll { $0.name == workoutName }
            if result.workouts.isEmpty { context.delete(result) }
        }
        try? context.save()
    }
}
