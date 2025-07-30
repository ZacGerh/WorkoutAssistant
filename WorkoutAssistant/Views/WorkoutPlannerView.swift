// ===== START FILE: WorkoutPlannerView.swift =====
// Workout Planner with temporary editing state, alternating colors, and delete functionality.

import SwiftUI
import SwiftData

// MARK: - Planner Button Style
struct PlannerButtonStyle: ButtonStyle {
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

// MARK: - TempWorkout (Ephemeral Data)
struct TempWorkout: Identifiable {
    let id: UUID
    var name: String
    var weight: Double
    var incrementWeight: Double
    var reps: Int
    var setCount: Int

    init(id: UUID = UUID(),
         name: String = "",
         weight: Double = 0.0,
         incrementWeight: Double = 5.0,
         reps: Int = 10,
         setCount: Int = 1) {
        self.id = id
        self.name = name
        self.weight = weight
        self.incrementWeight = incrementWeight
        self.reps = reps
        self.setCount = setCount
    }

    init(from workout: Workout) {
        self.id = workout.id
        self.name = workout.name
        self.weight = workout.weight
        self.incrementWeight = workout.incrementWeight
        self.reps = workout.initialReps
        self.setCount = workout.sets.count
    }

    func toWorkout() -> Workout {
        let sets = (0..<setCount).map { _ in WorkoutSet(reps: reps) }
        return Workout(
            id: id,
            name: name,
            weight: weight,
            incrementWeight: incrementWeight,
            initialReps: reps,
            sets: sets
        )
    }
}

// MARK: - Workout Planner View
struct WorkoutPlannerView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var tempWorkouts: [TempWorkout] = []
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
                ForEach(tempWorkouts.indices, id: \.self) { index in
                    plannerCard(for: index)
                }
            }

            HStack(spacing: 15) {
                Button("Add") { withAnimation { addWorkout() } }
                    .buttonStyle(PlannerButtonStyle(color: .blue))

                Button("Save") {
                    onSave?(tempWorkouts.map { $0.toWorkout() })
                    dismiss()
                }
                .buttonStyle(PlannerButtonStyle(color: .green))

                Button("Cancel") {
                    onCancel?()
                    dismiss()
                }
                .buttonStyle(PlannerButtonStyle(color: .red))
            }
        }
        .padding()
        .onAppear {
            tempWorkouts = existingWorkouts.map { TempWorkout(from: $0) }
        }
    }

    // MARK: - Helper UI
    private func plannerCard(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workout Name")
                .font(.caption)
                .foregroundColor(.gray)
            TextField("Workout Name", text: $tempWorkouts[index].name)
                .focused($focusedWorkoutID, equals: tempWorkouts[index].id)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("Starting Weight (\(settings.weightUnit.rawValue))")
                .font(.caption)
                .foregroundColor(.gray)
            TextField("Starting Weight", value: $tempWorkouts[index].weight, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("Increment Weight (\(settings.weightUnit.rawValue))")
                .font(.caption)
                .foregroundColor(.gray)
            TextField("Increment Weight", value: $tempWorkouts[index].incrementWeight, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Stepper(value: $tempWorkouts[index].setCount, in: 1...10) {
                Text("Number of Sets: \(tempWorkouts[index].setCount)")
            }

            Stepper(value: $tempWorkouts[index].reps, in: 1...20) {
                Text("Reps per Set: \(tempWorkouts[index].reps)")
            }

            Button(action: { withAnimation { deleteWorkout(at: index) } }) {
                Label("Delete Workout", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .padding(.top, 5)
        }
        .padding(.vertical, 5)
        .listRowBackground(index % 2 == 0 ? Color(UIColor.systemGray6) : Color(UIColor.systemGray5))
        .cornerRadius(8)
    }

    // MARK: - Logic
    private func addWorkout() {
        let newWorkout = TempWorkout(
            name: "New Workout",
            weight: settings.defaultStartingWeight,
            incrementWeight: settings.defaultIncrement
        )
        tempWorkouts.append(newWorkout)
        focusedWorkoutID = newWorkout.id
    }

    private func deleteWorkout(at index: Int) {
        tempWorkouts.remove(at: index)
    }
}

// ===== END FILE: WorkoutPlannerView.swift =====
