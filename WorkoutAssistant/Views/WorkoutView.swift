// WorkoutView.swift
import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var timerSeconds: Int? = nil
    @State private var currentTimer: Timer? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var onFinish: () -> Void = {}
    var openPlanner: () -> Void = {}

    private let successRestTime = 90
    private let failureRestTime = 180
    private let notStartedRestTime = 0
    private let columnWidths: [CGFloat] = [75, 75]
    private let verticalSpacing: CGFloat = 15
    private let horizontalSpacing: CGFloat = 5

    public init(onFinish: @escaping () -> Void = {}, openPlanner: @escaping () -> Void = {}) {
        self.onFinish = onFinish
        self.openPlanner = openPlanner
    }

    var body: some View {
        GeometryReader { geometry in
            let totalHorizontalPadding: CGFloat = 32
            let availableWidth = geometry.size.width - columnWidths[0] - columnWidths[1] - totalHorizontalPadding

            VStack {
                VStack(spacing: 5) {
                    Text("Today's Workout!")
                        .font(.largeTitle)
                        .bold()
                    Text(Date.now, style: .date)
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding(.top)

                ScrollView {
                    VStack(spacing: verticalSpacing) {
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
                            Text("Rest Timer: \\(seconds / 60):\\(String(format: \"%02d\", seconds % 60))")
                                .font(.title2)
                                .padding(.top, 20)
                        } else {
                            Text("Rest Timer: 0:00")
                                .font(.title2)
                                .padding(.top, 20)
                        }
                    }
                }

                Button(action: {
                    finishWorkout()
                    onFinish()
                }) {
                    Text("Finish Workout")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(allSetsSuccessful ? Color.green : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.vertical)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertMessage))
                }

                Button("Workout Planner") {
                    openPlanner()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.bottom)
            }
        }
        .onDisappear {
            currentTimer?.invalidate()
        }
    }

    private var allSetsSuccessful: Bool {
        for workout in workoutManager.workouts {
            for set in workout.sets {
                if case .success = set { continue } else { return false }
            }
        }
        return true
    }

    private func finishWorkout() {
        if allSetsSuccessful {
            alertMessage = "Workout Success!"
        } else {
            alertMessage = "Workout Failed :("
        }
        showAlert = true
    }

    private func handleSetTap(workoutIndex: Int, setIndex: Int, oldState: SetButton.SetState) {
        switch oldState {
        case .notStarted(let reps):
            workoutManager.workouts[workoutIndex].sets[setIndex] = .success(reps)
            startTimer(seconds: successRestTime)
        case .success(let reps):
            let newReps = max(reps - 1, 0)
            workoutManager.workouts[workoutIndex].sets[setIndex] = .failure(newReps)
            startTimer(seconds: failureRestTime)
        case .failure(let reps):
            let newReps = reps - 1
            if newReps < 0 {
                let initialReps = workoutManager.workouts[workoutIndex].initialReps
                workoutManager.workouts[workoutIndex].sets[setIndex] = .notStarted(initialReps)
                startTimer(seconds: notStartedRestTime)
            } else {
                workoutManager.workouts[workoutIndex].sets[setIndex] = .failure(newReps)
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
