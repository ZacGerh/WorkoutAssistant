//
//  HistoryWindow.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 8/12/25.
//


// ===== START FILE: HistorySummaryView.swift =====
import SwiftUI

enum HistoryWindow: String, CaseIterable, Identifiable {
    case today = "Today"
    case week = "This Week"
    case month = "This Month"
    case year = "This Year"
    case all = "All Time"

    var id: String { rawValue }

    func lowerBound(from now: Date = Date()) -> Date? {
        let cal = Calendar.current
        switch self {
        case .today:
            return cal.startOfDay(for: now)
        case .week:
            return cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
        case .month:
            let comps = cal.dateComponents([.year, .month], from: now)
            return cal.date(from: comps)
        case .year:
            let comps = cal.dateComponents([.year], from: now)
            return cal.date(from: comps)
        case .all:
            return nil
        }
    }
}

struct HistorySummaryView: View {
    @EnvironmentObject var settings: SettingsManager

    let results: [WorkoutResult]
    let workoutName: String? // nil = all workouts

    @State private var window: HistoryWindow = .all

    private var filteredResults: [WorkoutResult] {
        guard let lb = window.lowerBound() else { return results }
        return results.filter { $0.timestamp >= lb }
    }

    private var totalMiles: Double {
        filteredResults
            .filter { $0.runEnabled }
            .map { $0.runTotalMiles }
            .reduce(0, +)
    }

    private var totalTime: Double {
        filteredResults.map { $0.totalTime }.reduce(0, +)
    }

    private var avgTime: Double {
        guard !filteredResults.isEmpty else { return 0 }
        return totalTime / Double(filteredResults.count)
    }

    private var totalWeight: Double {
        // Sum only items for this workout (or all)
        let items: [WorkoutResultItem] = filteredResults.flatMap { $0.workouts }
            .filter { workoutName == nil || $0.name == workoutName }

        return items.reduce(0.0) { acc, item in
            // Back-compat: if snapshots are zero, treat as unknown -> 0 contribution
            guard item.totalSetsAtTime > 0, item.repsAtTime > 0 else { return acc }
            let successfulSets = max(0, item.totalSetsAtTime - item.failedReps.count)
            let volume = Double(successfulSets * item.repsAtTime) * item.weight
            return acc + volume
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Window", selection: $window) {
                ForEach(HistoryWindow.allCases) { w in
                    Text(w.rawValue).tag(w)
                }
            }
            .pickerStyle(.segmented)

            // Stat "cards"
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    statCell(title: "Total Miles Ran",
                             value: "\(formatNumber(totalMiles)) \(settings.runUnit.rawValue)")
                    statCell(title: "Total Time",
                             value: formatTotalTime(totalTime))
                }
                GridRow {
                    statCell(title: "Average Workout Time",
                             value: formatTotalTime(avgTime))
                    statCell(title: "Total Weight Lifted",
                             value: "\(formatNumber(totalWeight)) \(settings.weightUnit.rawValue)")
                }
            }
            .padding(12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.separator), lineWidth: 0.5))
            .cornerRadius(8)
        }
    }

    private func statCell(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatNumber(_ x: Double) -> String {
        if x.isNaN || x.isInfinite { return "0" }
        // show up to 3 decimals, trimming zeros
        let formatted = x.formatted(.number.grouping(.automatic).precision(.fractionLength(0...3)))
        return formatted
    }

    private func formatTotalTime(_ seconds: Double) -> String {
        let t = Int(seconds.rounded())
        let h = t / 3600
        let m = (t % 3600) / 60
        let s = t % 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }
}
// ===== END FILE: HistorySummaryView.swift =====
