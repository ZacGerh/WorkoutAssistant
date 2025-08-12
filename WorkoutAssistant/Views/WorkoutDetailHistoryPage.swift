// ===== START FILE: WorkoutDetailHistoryPage.swift =====
import SwiftUI
import SwiftData
import Charts

struct WorkoutDetailHistoryPage: View {
    @Environment(\.modelContext) private var context
    @State private var pendingDelete: Occurrence? = nil

    // Time window picker (reuses HistoryWindow from HistorySummaryView.swift)
    @State private var window: HistoryWindow = .all

    let results: [WorkoutResult]
    let workoutName: String

    struct Occurrence: Identifiable {
        let id: String
        let result: WorkoutResult
        let item: WorkoutResultItem
        let timestamp: Date
        let weight: Double
        let success: Bool
    }

    private var occurrences: [Occurrence] {
        results.compactMap { result in
            guard let item = result.workouts.first(where: { $0.name == workoutName }) else { return nil }
            return Occurrence(
                id: result.id.uuidString + "-" + item.id.uuidString,
                result: result,
                item: item,
                timestamp: result.timestamp,
                weight: item.weight,
                success: item.success
            )
        }
        .sorted { $0.timestamp < $1.timestamp }
    }

    private var filteredOccurrences: [Occurrence] {
        guard let lb = window.lowerBound() else { return occurrences }
        return occurrences.filter { $0.timestamp >= lb }
    }

    var body: some View {
        VStack(spacing: 12) {
            if occurrences.isEmpty {
                Text("No history found for \(workoutName).")
                    .foregroundColor(.gray)
            } else {
                // Window control (affects chart + list)
                Picker("Window", selection: $window) {
                    ForEach(HistoryWindow.allCases) { w in
                        Text(w.rawValue).tag(w)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Chart: Weight by Date with markers (filtered)
                if filteredOccurrences.isEmpty {
                    Text("No entries in this range.")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                } else {
                    Chart(filteredOccurrences) { occ in
                        LineMark(
                            x: .value("Date", occ.timestamp),
                            y: .value("Weight", occ.weight)
                        )
                        .symbol(.circle)
                        .foregroundStyle(occ.success ? .green : .red)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", occ.timestamp),
                            y: .value("Weight", occ.weight)
                        )
                        .foregroundStyle(occ.success ? .green : .red)
                        .annotation(position: .top) {
                            Text("\(Int(occ.weight))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                    .padding(.top, 4)
                }

                // List of results (filtered for the same window)
                List {
                    ForEach(filteredOccurrences.reversed()) { occ in // newest first
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(formatDate(occ.timestamp))
                                    .font(.headline)
                                Spacer()
                                Button {
                                    pendingDelete = occ
                                } label: {
                                    Image(systemName: "trash")
                                        .imageScale(.small)
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.red)
                                .accessibilityLabel("Delete entry")
                            }
                            Text("Weight: \(Int(occ.weight)) lbs")
                            Text("Result: \(occ.success ? "Success" : "Failure")")
                                .foregroundColor(occ.success ? .green : .red)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .navigationTitle(workoutName)
        // Per-entry delete confirmation
        .alert("Delete this entry?", isPresented: Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { pendingDelete = nil }
            Button("Delete", role: .destructive) {
                if let occ = pendingDelete {
                    context.delete(occ.item)
                    occ.result.workouts.removeAll { $0 === occ.item }
                    if occ.result.workouts.isEmpty { context.delete(occ.result) }
                    try? context.save()
                }
                pendingDelete = nil
            }
        } message: {
            Text("This will remove this workout entry from the selected session.")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
// ===== END FILE: WorkoutDetailHistoryPage.swift =====
