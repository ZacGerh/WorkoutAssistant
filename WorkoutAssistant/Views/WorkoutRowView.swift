import SwiftUI

public struct WorkoutRowView: View {
    @Binding var workout: Workout
    public let availableWidth: CGFloat
    public let columnWidths: [CGFloat]
    public let verticalSpacing: CGFloat
    public let horizontalSpacing: CGFloat
    public let onSetTap: (SetButton.SetState, Int) -> Void // Use SetButton.SetState directly

    init(workout: Binding<Workout>,
         availableWidth: CGFloat,
         columnWidths: [CGFloat],
         verticalSpacing: CGFloat,
         horizontalSpacing: CGFloat,
         onSetTap: @escaping (SetButton.SetState, Int) -> Void) {
        self._workout = workout
        self.availableWidth = availableWidth
        self.columnWidths = columnWidths
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.onSetTap = onSetTap
    }

    public var body: some View {
        let setsCount = workout.sets.count
        let columnsCount = max(Int(availableWidth / (50 + horizontalSpacing)), 1)
        let rows = (setsCount + columnsCount - 1) / columnsCount
        let rowHeight = CGFloat(rows) * (50 + verticalSpacing) - verticalSpacing

        GridRow {
            Text(workout.name)
                .frame(maxWidth: columnWidths[0], alignment: .center)
                .frame(height: rowHeight)
            Text("\(Int(workout.weight))")
                .frame(maxWidth: columnWidths[1], alignment: .center)
                .frame(height: rowHeight)

            let columns = Array(repeating: GridItem(.fixed(50), spacing: horizontalSpacing), count: columnsCount)

            LazyVGrid(columns: columns, alignment: .leading, spacing: verticalSpacing) {
                ForEach(0..<workout.sets.count, id: \.self) { setIndex in
                    let setItem = workout.sets[setIndex]
                    SetButton(
                        state: Binding(
                            get: { convertToSetState(setItem) },
                            set: { newState in
                                workout.sets[setIndex] = convertFromSetState(newState)
                            }
                        ),
                        onTap: { newState in
                            onSetTap(newState, setIndex)
                        }
                    )
                }
            }
            .frame(maxWidth: availableWidth, alignment: .leading)
            .frame(height: rowHeight)
            .animation(.default, value: columnsCount)
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }

    // MARK: - Helpers to bridge WorkoutSet and SetButton.SetState
    private func convertToSetState(_ set: WorkoutSet) -> SetButton.SetState {
        switch set.state {
        case "success": return .success(set.reps)
        case "failure": return .failure(set.reps)
        default: return .notStarted(set.reps)
        }
    }

    private func convertFromSetState(_ state: SetButton.SetState) -> WorkoutSet {
        switch state {
        case .success(let reps): return WorkoutSet(reps: reps, state: "success")
        case .failure(let reps): return WorkoutSet(reps: reps, state: "failure")
        case .notStarted(let reps): return WorkoutSet(reps: reps, state: "notStarted")
        }
    }
}
