import SwiftUI
import SwiftData
import Charts

struct WorkoutDetailHistoryPage: View {
    @Environment(\.modelContext) private var context
    @State private var pendingDelete: Occurrence? = nil

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

    var body: some View {
        VStack {
            if occurrences.isEmpty {
                Text("No history found for \(workoutName).")
                    .foregroundColor(.gray)
            } else {
                Chart(occurrences) { occ in
                    LineMark(
                        x: .value("Date", occ.timestamp),
                        y: .value("Weight", occ.weight)
                    )
                    .symbol(.circle)
                    .foregroundStyle(occ.success ? .green : .red)
                    .annotation(position: .top) {
                        Text("\(Int(occ.weight))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 200)
                .padding()

                List {
                    ForEach(occurrences) { occ in
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
        .alert("Delete this \(workoutName) entry?", isPresented: Binding(
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
