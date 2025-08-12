import SwiftUI
import SwiftData
import Charts

struct WorkoutHistoryOverviewPage: View {
    @Environment(\.modelContext) private var context
    @State private var pendingDelete: WorkoutResult? = nil

    let results: [WorkoutResult]

    var body: some View {
        VStack {
            if results.isEmpty {
                Text("No workout history found.")
                    .foregroundColor(.gray)
            } else {
                Chart(results) { result in
                    BarMark(
                        x: .value("Date", result.timestamp),
                        y: .value("Success", result.overallSuccess ? 1 : 0)
                    )
                    .foregroundStyle(result.overallSuccess ? .green : .red)
                }
                .frame(height: 200)
                .padding()

                List {
                    ForEach(results) { result in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(result.timestamp, style: .date)
                                    .font(.headline)
                                Spacer()
                                Button {
                                    pendingDelete = result
                                } label: {
                                    Image(systemName: "trash")
                                        .imageScale(.small)
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.red)
                                .accessibilityLabel("Delete session")
                            }

                            Text("Duration: \(formatTime(result.totalTime))")
                            Text("Overall Result: \(result.overallSuccess ? "Success" : "Failure")")
                                .foregroundColor(result.overallSuccess ? .green : .red)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        // Per-row delete confirmation
        .alert("Delete this session?", isPresented: Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { pendingDelete = nil }
            Button("Delete", role: .destructive) {
                if let r = pendingDelete {
                    for item in r.workouts { context.delete(item) }
                    context.delete(r)
                    try? context.save()
                }
                pendingDelete = nil
            }
        } message: {
            Text("This will remove the selected session from your history.")
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds / 60)
        let remaining = Int(seconds.truncatingRemainder(dividingBy: 60))
        return "\(minutes)m \(remaining)s"
    }
}
