import SwiftUI

enum WeightUnit: String, CaseIterable, Identifiable {
    case lbs = "Lbs"
    case kg = "Kg"
    var id: String { rawValue }
}

// NEW
enum RunUnit: String, CaseIterable, Identifiable {
    case miles = "Miles"
    case km = "Km"
    var id: String { rawValue }
}

class SettingsManager: ObservableObject {
    @AppStorage("incrementAfterSuccess") var incrementAfterSuccess: Int = 1
    @AppStorage("decrementAfterFailures") var decrementAfterFailures: Int = 1
    @AppStorage("usePercentageForDecrement") var usePercentageForDecrement: Bool = true
    @AppStorage("decrementPercentage") var decrementPercentage: Double = 50
    @AppStorage("defaultDecrement") var defaultDecrement: Double = 5
    @AppStorage("defaultStartingWeight") var defaultStartingWeight: Double = 45
    @AppStorage("defaultIncrement") var defaultIncrement: Double = 5
    @AppStorage("weightTolerance") var weightTolerance: Double = 5

    @AppStorage("defaultSets") var defaultSets: Int = 3
    @AppStorage("defaultReps") var defaultReps: Int = 10

    @AppStorage("weightUnit") var weightUnitRaw: String = WeightUnit.lbs.rawValue
    var weightUnit: WeightUnit {
        get { WeightUnit(rawValue: weightUnitRaw) ?? .lbs }
        set { weightUnitRaw = newValue.rawValue }
    }

    // NEW – Run unit lives in Settings (label only; no conversion math)
    @AppStorage("runUnit") private var runUnitRaw: String = RunUnit.miles.rawValue
    var runUnit: RunUnit {
        get { RunUnit(rawValue: runUnitRaw) ?? .miles }
        set { runUnitRaw = newValue.rawValue }
    }
}
