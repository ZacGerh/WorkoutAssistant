// ===== START FILE: SettingsView.swift =====
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager

    var body: some View {
        Form {
            Section(header: Text("Progressive Loading Rules")) {
                Stepper("Increase weight after \(settings.incrementAfterSuccess) success(es)",
                        value: $settings.incrementAfterSuccess, in: 1...99)
            }

            Section(header: Text("Decrement Rules")) {
                Stepper("Decrement after \(settings.decrementAfterFailures) failures",
                        value: $settings.decrementAfterFailures, in: 1...99)
                Toggle("Use Percentage for Decrement", isOn: $settings.usePercentageForDecrement)
                if settings.usePercentageForDecrement {
                    Stepper("Decrement Percentage: \(Int(settings.decrementPercentage))%",
                            value: $settings.decrementPercentage, in: 1...100)
                } else {
                    Stepper("Default Decrement: \(Int(settings.defaultDecrement)) \(settings.weightUnit.rawValue)",
                            value: $settings.defaultDecrement, in: 1...50)
                }
            }

            Section(header: Text("Default Values")) {
                Stepper("Default Starting Weight: \(Int(settings.defaultStartingWeight)) \(settings.weightUnit.rawValue)",
                        value: $settings.defaultStartingWeight, in: 0...500)
                Stepper("Default Increment: \(Int(settings.defaultIncrement)) \(settings.weightUnit.rawValue)",
                        value: $settings.defaultIncrement, in: 1...50)
                Stepper("Weight Tolerance: \(Int(settings.weightTolerance)) \(settings.weightUnit.rawValue)",
                        value: $settings.weightTolerance, in: 1...50)
                Stepper("Default Sets: \(settings.defaultSets)",
                        value: $settings.defaultSets, in: 1...10)
                Stepper("Default Reps: \(settings.defaultReps)",
                        value: $settings.defaultReps, in: 1...50)
            }

            Section(header: Text("Units")) {
                Picker("Weight Unit", selection: $settings.weightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                
                Section(header: Text("Units")) {
                    Picker("Weight Unit", selection: $settings.weightUnit) {
                        ForEach(WeightUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)

                    // NEW
                    Picker("Run Unit", selection: $settings.runUnit) {
                        ForEach(RunUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }

            }
        }
        .navigationTitle("Settings")
    }
}
// ===== END FILE: SettingsView.swift =====
