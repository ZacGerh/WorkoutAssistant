import SwiftUI
import SwiftData

// MARK: - Planner Button Style
struct PlannerButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(6)
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .foregroundColor(.white)
            .cornerRadius(6)
    }
}

// MARK: - CustomWeight (Identifiable)
struct CustomWeight: Identifiable, Hashable {
    var id = UUID()
    var weight: Double
    var count: Int
}

// MARK: - TempWorkout (Ephemeral Data)
struct TempWorkout: Identifiable {
    let id: UUID
    var name: String
    var weight: Double
    var incrementWeight: Double
    var reps: Int
    var setCount: Int
    var useCustomWeights: Bool
    var customWeights: [CustomWeight]

    init(id: UUID = UUID(),
         name: String = "",
         weight: Double = 0.0,
         incrementWeight: Double = 5.0,
         reps: Int = 10,
         setCount: Int = 3,
         useCustomWeights: Bool = false,
         customWeights: [CustomWeight] = [CustomWeight(weight: 45, count: 1)]) {
        self.id = id
        self.name = name
        self.weight = weight
        self.incrementWeight = incrementWeight
        self.reps = reps
        self.setCount = setCount
        self.useCustomWeights = useCustomWeights
        self.customWeights = customWeights
    }

    init(from workout: Workout) {
        self.id = workout.id
        self.name = workout.name
        self.weight = workout.weight
        self.incrementWeight = workout.incrementWeight
        self.reps = workout.initialReps
        self.setCount = workout.sets.count
        self.useCustomWeights = false
        self.customWeights = [CustomWeight(weight: workout.weight, count: 1)]
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

            Toggle("Custom Weight Setup", isOn: $tempWorkouts[index].useCustomWeights)
                .padding(.vertical, 4)

            if tempWorkouts[index].useCustomWeights {
                customWeightsGrid(for: index)
            }

            // Set and Rep Count
            HStack {
                Text("Set Count")
                    .frame(width: 120, alignment: .leading)
                Stepper(value: $tempWorkouts[index].setCount, in: 1...10) {
                    Text("\(tempWorkouts[index].setCount)")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            HStack {
                Text("Rep Count")
                    .frame(width: 120, alignment: .leading)
                Stepper(value: $tempWorkouts[index].reps, in: 1...20) {
                    Text("\(tempWorkouts[index].reps)")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            // Delete Workout Button
            Button(action: { withAnimation { deleteWorkout(at: index) } }) {
                Label("Delete Workout", systemImage: "trash")
                    .foregroundColor(.red)
            }
            .padding(.top, 5)
        }
        .padding(.vertical, 8)
        .listRowBackground(index % 2 == 0 ? Color(UIColor.systemGray6) : Color(UIColor.systemGray5))
        .cornerRadius(8)
    }

    private func customWeightsGrid(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header row
            HStack {
                Text("Weight (\(settings.weightUnit.rawValue))")
                    .frame(width: 120, alignment: .leading)
                Text("Count")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.caption)
            .foregroundColor(.gray)

            // Rows
            ForEach(tempWorkouts[index].customWeights, id: \.id) { customWeight in
                HStack(spacing: 8) {
                    Button(action: {
                        removeWeightRow(at: index, weightID: customWeight.id)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 24)
                    }
                    .buttonStyle(.borderless) // Applying borderless button style

                    TextField("0", value: binding(for: customWeight, in: index).weight, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Stepper(value: binding(for: customWeight, in: index).count, in: 1...10) {
                        Text("\(binding(for: customWeight, in: index).count.wrappedValue)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            Button(action: { addWeightRow(at: index) }) {
                Text("Add Weight")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlannerButtonStyle(color: .blue))
            .padding(.top, 4)
        }
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

    private func addWeightRow(at index: Int) {
        guard index < tempWorkouts.count else { return }
        tempWorkouts[index].customWeights.append(CustomWeight(weight: settings.defaultStartingWeight, count: 1))
    }

    private func removeWeightRow(at index: Int, weightID: UUID) {
        guard index < tempWorkouts.count else { return }
        var workout = tempWorkouts[index]
        if let weightIndex = workout.customWeights.firstIndex(where: { $0.id == weightID }) {
            workout.customWeights.remove(at: weightIndex)
            tempWorkouts[index] = workout
        }
    }

    private func binding(for customWeight: CustomWeight, in index: Int) -> Binding<CustomWeight> {
        return $tempWorkouts[index].customWeights.first(where: { $0.id == customWeight.id }) ?? Binding.constant(customWeight)
    }
}

// ===== END FILE: WorkoutPlannerView.swift =====
