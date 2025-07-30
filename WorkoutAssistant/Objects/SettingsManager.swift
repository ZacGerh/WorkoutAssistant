import SwiftUI

enum WeightUnit: String, CaseIterable, Identifiable {
    case lbs = "Lbs"
    case kg = "Kg"

    var id: String { rawValue }
}

class SettingsManager: ObservableObject {
    @AppStorage("incrementAfterSuccess") var incrementAfterSuccess: Int = 1
    @AppStorage("decrementAfterFailures") var decrementAfterFailures: Int = 1
    @AppStorage("usePercentageForDecrement") var usePercentageForDecrement: Bool = true
    @AppStorage("decrementPercentage") var decrementPercentage: Double = 50
    @AppStorage("defaultDecrement") var defaultDecrement: Double = 5   // NEW: Decrement weight (lbs/kg)
    @AppStorage("defaultStartingWeight") var defaultStartingWeight: Double = 45
    @AppStorage("defaultIncrement") var defaultIncrement: Double = 5   // Increment weight (lbs/kg)
    @AppStorage("weightTolerance") var weightTolerance: Double = 5     // NEW: Rounding tolerance
    @AppStorage("weightUnit") var weightUnitRaw: String = WeightUnit.lbs.rawValue

    var weightUnit: WeightUnit {
        get { WeightUnit(rawValue: weightUnitRaw) ?? .lbs }
        set { weightUnitRaw = newValue.rawValue }
    }
}
