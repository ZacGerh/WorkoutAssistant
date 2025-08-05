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

            // ===== in CustomWeightGridView.swift, inside your ForEach row =====
            ForEach(plannedWorkout.customWeights, id: \.id) { customWeight in
                HStack(spacing: 8) {
                    Button {
                        removeWeightRow(weightID: customWeight.id)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 24)
                    }
                    .buttonStyle(.borderless)

                    // 1) Grab the binding to the Double weight
                    let weightBinding = binding(for: customWeight).weight

                    // 2) Wrap it in a String-binding that treats empty text as 0
                    let textBinding = Binding<String>(
                        get: {
                            let w = weightBinding.wrappedValue
                            // show as "50" if whole, otherwise full double
                            return (w.truncatingRemainder(dividingBy: 1) == 0)
                                ? String(Int(w))
                                : String(w)
                        },
                        set: { txt in
                            if let v = Double(txt) {
                                weightBinding.wrappedValue = v
                            } else if txt.isEmpty {
                                weightBinding.wrappedValue = 0
                            }
                            // otherwise ignore non-numeric
                        }
                    )

                    // 3) Use the String-based TextField
                    TextField("0", text: textBinding)
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
                    .frame(height: 5)
            }
            .buttonStyle(PlannerButtonStyle(color: .blue))
            .padding(.top, 0)
            
        }
    }

    private func binding(for customWeight: WeightCount) -> Binding<WeightCount> {
        return $plannedWorkout.customWeights.first(where: { $0.id == customWeight.id }) ?? Binding.constant(customWeight)
    }

    private func addWeightRow() {
        plannedWorkout.customWeights.append(WeightCount(weight: settings.defaultStartingWeight, count: 1))
    }

    private func removeWeightRow(weightID: UUID) {
        plannedWorkout.customWeights.removeAll { $0.id == weightID }
    }
}
