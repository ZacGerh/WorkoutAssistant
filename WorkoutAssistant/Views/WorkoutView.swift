import SwiftUI

// MARK: - WorkoutView with GeometryReader and ScrollView using WorkoutManager
public struct WorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var timerSeconds: Int? = nil
    @State private var currentTimer: Timer? = nil

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
                    Grid(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
                        // Header Row
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
                        ForEach(workoutManager.workouts.indices, id: \.self) { index in
                            WorkoutRowView(
                                workout: $workoutManager.workouts[index],
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

    private func handleSetTap(workoutIndex: Int, setIndex: Int, oldState: SetButton.SetState) {
        switch oldState {
        case .notStarted(let reps):
            workoutManager.workouts[workoutIndex].sets[setIndex] = SetButton.SetState.success(reps)
            startTimer(seconds: successRestTime)
        case .success(let reps):
            let newReps = max(reps - 1, 0)
            workoutManager.workouts[workoutIndex].sets[setIndex] = SetButton.SetState.failure(newReps)
            startTimer(seconds: failureRestTime)
        case .failure(let reps):
            let newReps = reps - 1
            if newReps < 0 {
                workoutManager.workouts[workoutIndex].sets[setIndex] = SetButton.SetState.notStarted(workoutManager.workouts[workoutIndex].reps)
                startTimer(seconds: notStartedRestTime)
            } else {
                workoutManager.workouts[workoutIndex].sets[setIndex] = SetButton.SetState.failure(newReps)
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
