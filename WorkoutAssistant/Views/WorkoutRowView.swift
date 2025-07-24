//
//  WorkoutRowView.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/23/25.
//

import SwiftUI

public struct WorkoutRowView: View {
    @Binding public var workout: Workout
    let availableWidth: CGFloat
    let columnWidths: [CGFloat]
    let verticalSpacing: CGFloat
    let horizontalSpacing: CGFloat
    let onSetTap: (SetState, Int) -> Void

    public init(workout: Binding<Workout>,
                availableWidth: CGFloat,
                columnWidths: [CGFloat],
                verticalSpacing: CGFloat,
                horizontalSpacing: CGFloat,
                onSetTap: @escaping (SetState, Int) -> Void) {
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
            Text("\(workout.weight)")
                .frame(maxWidth: columnWidths[1], alignment: .center)
                .frame(height: rowHeight)

            let columns = Array(repeating: GridItem(.fixed(50), spacing: horizontalSpacing), count: columnsCount)

            LazyVGrid(columns: columns, alignment: .leading, spacing: verticalSpacing) {
                ForEach(workout.sets.indices, id: \.self) { setIndex in
                    SetButton(state: $workout.sets[setIndex].state) { oldState in
                        onSetTap(oldState, setIndex)
                    }
                }
            }
            .frame(maxWidth: availableWidth, alignment: .leading)
            .frame(height: rowHeight)
            .animation(.default, value: columnsCount)
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}
