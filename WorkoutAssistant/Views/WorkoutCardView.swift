import SwiftUI
import SwiftData

struct WorkoutCardView: View {
    @Binding var plannedWorkout: PlannedWorkout
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Workout Name
            Text("Workout Name")
                .font(.caption)
                .foregroundColor(.gray)
            TextField("Workout Name", text: $plannedWorkout.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Starting Weight
            Text("Starting Weight (\(settings.weightUnit.rawValue))")
                .font(.caption)
                .foregroundColor(.gray)
            TextField("Starting Weight", value: $plannedWorkout.weight, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Increment Weight
            Text("Increment Weight (\(settings.weightUnit.rawValue))")
                .font(.caption)
                .foregroundColor(.gray)
            TextField("Increment Weight", value: $plannedWorkout.incrementWeight, format: .number)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // Custom Weight Setup Toggle
            Toggle("Custom Weight Setup", isOn: $plannedWorkout.useCustomWeights)
                .padding(.vertical, 4)

            // Custom Weight Grid if enabled
            if plannedWorkout.useCustomWeights {
                CustomWeightGridView(plannedWorkout: $plannedWorkout)
            }

            // Set Count
            HStack {
                Text("Set Count")
                    .frame(width: 120, alignment: .leading)
                Stepper(value: $plannedWorkout.setCount, in: 1...10) {
                    Text("\(plannedWorkout.setCount)")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            // Rep Count
            HStack {
                Text("Rep Count")
                    .frame(width: 120, alignment: .leading)
                Stepper(value: $plannedWorkout.initialReps, in: 1...20) {
                    Text("\(plannedWorkout.initialReps)")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding(.vertical, 8)
        .listRowBackground(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}
