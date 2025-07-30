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
                }
            }

            Section(header: Text("Default Values")) {
                Stepper("Default Starting Weight: \(Int(settings.defaultStartingWeight)) \(settings.weightUnit.rawValue)",
                        value: $settings.defaultStartingWeight, in: 0...500)
                Stepper("Default Increment: \(Int(settings.defaultIncrement)) \(settings.weightUnit.rawValue)",
                        value: $settings.defaultIncrement, in: 1...50)
            }

            Section(header: Text("Units")) {
                Picker("Weight Unit", selection: $settings.weightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Settings")
    }
}
