import SwiftUI

struct CustomWeightGridView: View {
    @Binding var plannedWorkout: PlannedWorkout
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Weight (\(settings.weightUnit.rawValue))")
                    .frame(width: 120, alignment: .leading)
                Text("Count")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.caption)
            .foregroundColor(.gray)

            ForEach(plannedWorkout.customWeights, id: \.id) { customWeight in
                HStack(spacing: 8) {
                    Button(action: {
                        removeWeightRow(weightID: customWeight.id)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 24)
                    }
                    .buttonStyle(.borderless)

                    TextField("0", value: binding(for: customWeight).weight, format: .number)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Stepper(value: binding(for: customWeight).count, in: 1...10) {
                        Text("\(binding(for: customWeight).count.wrappedValue)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            Button(action: { addWeightRow() }) {
                Text("Add Weight")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlannerButtonStyle(color: .blue))
            .padding(.top, 4)
        }
    }

    private func binding(for customWeight: CustomWeight) -> Binding<CustomWeight> {
        return $plannedWorkout.customWeights.first(where: { $0.id == customWeight.id }) ?? Binding.constant(customWeight)
    }

    private func addWeightRow() {
        plannedWorkout.customWeights.append(CustomWeight(weight: settings.defaultStartingWeight, count: 1))
    }

    private func removeWeightRow(weightID: UUID) {
        plannedWorkout.customWeights.removeAll { $0.id == weightID }
    }
}
