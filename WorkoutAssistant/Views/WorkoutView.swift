//
//  WorkoutView.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/23/25.
//

import SwiftUI

public struct WorkoutView: View {
    @State private var timerSeconds: Int? = nil
    @State private var currentTimer: Timer? = nil
    @State private var workouts: [Workout] = [
        Workout(name: "Chest Press", weight: 45, sets: [
            WorkoutSet(state: .notStarted(10), reps: 10),
            WorkoutSet(state: .notStarted(10), reps: 10),
            WorkoutSet(state: .notStarted(10), reps: 10)
        ]),
        Workout(name: "This Is A Really Long Name", weight: 50, sets: [
            WorkoutSet(state: .notStarted(8), reps: 8),
            WorkoutSet(state: .notStarted(7), reps: 7),
            WorkoutSet(state: .notStarted(6), reps: 6)
        ]),
        Workout(name: "5 by 5", weight: 55, sets: [
            WorkoutSet(state: .notStarted(5), reps: 5),
            WorkoutSet(state: .notStarted(5), reps: 5),
            WorkoutSet(state: .notStarted(5), reps: 5),
            WorkoutSet(state: .notStarted(5), reps: 5),
            WorkoutSet(state: .notStarted(5), reps: 5)
        ]),

    ]

    // MARK: - Constants for WorkoutView

    private let successRestTime = 90
    private let failureRestTime = 180
    private let notStartedRestTime = 0
    private let setButtonSize: CGFloat = 50
    private let longPressDuration = 2.0
    private let columnWidths: [CGFloat] = [75, 75]
    private let verticalSpacing: CGFloat = 15
    private let horizontalSpacing: CGFloat = 5

    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            let totalHorizontalPadding: CGFloat = 32
            let availableWidth = geometry.size.width - columnWidths[0] - columnWidths[1] - totalHorizontalPadding

            ScrollView {
                VStack(spacing: verticalSpacing) {
                    // Header GridRow
                    Grid(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
                        GridRow {
                            Text("Workout")
                                .bold()
                                .frame(maxWidth: columnWidths[0], alignment: .center)
                            Text("Weight")
                                .bold()
                                .frame(maxWidth: columnWidths[1], alignment: .center)
                            Text("Sets and Reps")
                                .bold()
                                .frame(maxWidth: availableWidth, alignment: .leading)
                        }

                        // Workout Rows
                        ForEach(workouts.indices, id: \.self) { index in
                            WorkoutRowView(
                                workout: $workouts[index],
                                availableWidth: availableWidth,
                                columnWidths: columnWidths,
                                verticalSpacing: verticalSpacing,
                                horizontalSpacing: horizontalSpacing
                            ) { oldState, setIndex in
                                handleSetTap(workoutIndex: index, setIndex: setIndex, oldState: oldState)
                            }
                        }
                    }
                    .padding(.horizontal)

                    if let seconds = timerSeconds {
                        Text("Rest Timer: \(seconds / 60):\(String(format: "%02d", seconds % 60))")
                            .font(.title2)
                            .padding(.top, 20)
                    } else {
                        Text("Rest Timer: 0:00")
                            .font(.title2)
                            .padding(.top, 20)
                    }

                    Spacer()
                }
                .padding(.top)
            }
        }
        .onDisappear {
            currentTimer?.invalidate()
        }
    }

    private func handleSetTap(workoutIndex: Int, setIndex: Int, oldState: SetState) {
        switch oldState {
        case .notStarted(let reps):
            workouts[workoutIndex].sets[setIndex].state = .success(reps)
            startTimer(seconds: successRestTime)
        case .success(let reps):
            let newReps = max(reps - 1, 0)
            workouts[workoutIndex].sets[setIndex].state = .failure(newReps)
            startTimer(seconds: failureRestTime)
        case .failure(let reps):
            let newReps = reps - 1
            if newReps < 0 {
                workouts[workoutIndex].sets[setIndex].state = .notStarted(workouts[workoutIndex].sets[setIndex].reps)
                startTimer(seconds: notStartedRestTime)
            } else {
                workouts[workoutIndex].sets[setIndex].state = .failure(newReps)
                startTimer(seconds: failureRestTime)
            }
        }
    }

    private func startTimer(seconds: Int) {
        currentTimer?.invalidate()
        timerSeconds = seconds
        currentTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if let time = timerSeconds, time > 0 {
                timerSeconds = time - 1
            } else {
                timer.invalidate()
                timerSeconds = nil
            }
        }
    }
}
