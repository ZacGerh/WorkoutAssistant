import SwiftUI
import SwiftData
import Charts

struct WorkoutHistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WorkoutResult.timestamp, order: .reverse) private var results: [WorkoutResult]

    @State private var confirmClearAll = false
    @State private var pendingDelete: WorkoutResult? = nil

    var body: some View {
        List {
            if results.isEmpty {
                Text("No workout history found.")
                    .foregroundColor(.gray)
            } else {
                ForEach(results) { result in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(result.timestamp, style: .date)
                                .font(.headline)
                            Spacer()
                            Button(role: .destructive) {
                                pendingDelete = result
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .buttonStyle(.bordered)        // or .borderedProminent
                            .tint(.red)
                        }

                        Text("Duration: \(formatTime(result.totalTime))")
                        Text("Overall Result: \(result.overallSuccess ? "Success" : "Failure")")
                            .foregroundColor(result.overallSuccess ? .green : .red)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Workout History")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !results.isEmpty {
                    Button(role: .destructive) {
                        confirmClearAll = true
                    } label: {
                        Label("Clear All", systemImage: "trash")
                    }
                }
            }
        }
        // Confirm delete for a single session
        .alert("Delete this session?", isPresented: Binding(
            get: { pendingDelete != nil },
            set: { if !$0 { pendingDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) { pendingDelete = nil }
            Button("Delete", role: .destructive) {
                if let r = pendingDelete { deleteSession(r) }
                pendingDelete = nil
            }
        } message: {
            Text("This will remove the selected session from your history.")
        }
        // Confirm clear all
        .alert("Delete all history?", isPresented: $confirmClearAll) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { clearAllHistory() }
        } message: {
            Text("This will remove every saved workout session.")
        }
        .onAppear {
            print("Loaded \(results.count) workout results from SwiftData.")
        }
    }

    private func deleteSession(_ result: WorkoutResult) {
        context.delete(result)
        try? context.save()
    }

    private func clearAllHistory() {
        let descriptor = FetchDescriptor<WorkoutResult>()
        if let all = try? context.fetch(descriptor) {
            for r in all { context.delete(r) }
            try? context.save()
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds / 60)
        let remaining = Int(seconds.truncatingRemainder(dividingBy: 60))
        return "\(minutes)m \(remaining)s"
    }
}
