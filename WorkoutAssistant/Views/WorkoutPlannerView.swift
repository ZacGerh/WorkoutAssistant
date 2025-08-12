// ===== START FILE: WorkoutPlannerView.swift =====
import SwiftUI
import SwiftData

struct WorkoutPlannerView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // Make order deterministic so "first" is stable
    @Query(sort: \WorkoutPlan.id, order: .forward) private var plans: [WorkoutPlan]
    @State private var plan: WorkoutPlan? = nil

    @State private var tempWorkouts: [PlannedWorkout] = []

    var onSave: (([Workout]) -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    var existingWorkouts: [Workout] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Planner")
                .font(.largeTitle).bold()

            if let plan {
                @Bindable var bind = plan
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Include Run Section", isOn: $bind.includeRunSection)
                        .onChange(of: bind.includeRunSection) { _, _ in
                            try? context.save()
                        }

                    if bind.includeRunSection {
                        HStack(spacing: 12) {
                            Text("Run Goal")
                            TextField("0", text: bindingForDouble($bind.runGoalDistance))
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text(settings.runUnit.rawValue).foregroundColor(.secondary)
                        }

                        HStack(spacing: 12) {
                            Text("Default Lap")
                            TextField("0", text: bindingForDouble($bind.defaultLapDistance))
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text(settings.runUnit.rawValue).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.separator), lineWidth: 0.5))
                .cornerRadius(8)
            }

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
            workoutManager.loadWorkouts(context: context)
            tempWorkouts = workoutManager.workouts.map { PlannedWorkout(from: $0) }
            ensureSinglePlan()
        }
        .onDisappear {
            try? context.save()
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
        // Save workouts
        let workouts = tempWorkouts.map { $0.toWorkout() }
        onSave?(workouts)
        // Persist plan edits too
        try? context.save()
        dismiss()
    }

    private func cancelWorkouts() {
        onCancel?()
        dismiss()
    }

    /// Keep exactly one WorkoutPlan row so all screens read/write the same one.
    private func ensureSinglePlan() {
        if plans.isEmpty {
            let p = WorkoutPlan()
            context.insert(p)
            try? context.save()
            plan = p
            return
        }
        if plans.count > 1 {
            for extra in plans.dropFirst() { context.delete(extra) }
            try? context.save()
        }
        plan = plans.first
    }

    /// Double <-> String helper that also saves after edits
    private func bindingForDouble(_ doubleBinding: Binding<Double>) -> Binding<String> {
        Binding<String>(
            get: {
                let v = doubleBinding.wrappedValue
                return v.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(v)) : String(v)
            },
            set: { txt in
                if txt.isEmpty { doubleBinding.wrappedValue = 0 }
                else if let v = Double(txt) { doubleBinding.wrappedValue = v }
                try? context.save()
            }
        )
    }
}
// ===== END FILE: WorkoutPlannerView.swift =====
