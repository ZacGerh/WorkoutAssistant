//
//  WorkoutPlannerView.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/23/25.
//

import SwiftUI

public struct WorkoutPlannerView: View {
    @State private var workouts: [Workout] = []
    @State private var showAddWorkoutSheet = false

    public init() {}

    public var body: some View {
        NavigationView {
            VStack {
                if workouts.isEmpty {
                    Text("No workouts planned yet")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(workouts.indices, id: \.self) { index in
                                WorkoutRowView(
                                    workout: $workouts[index],
                                    availableWidth: UIScreen.main.bounds.width - 170,
                                    columnWidths: [75, 75],
                                    verticalSpacing: 15,
                                    horizontalSpacing: 5
                                ) { _, _ in
                                    // Planner might not have tap handling initially
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Workout Planner")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddWorkoutSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddWorkoutSheet) {
                AddWorkoutView(workouts: $workouts)
            }
        }
    }
}
