// WorkoutView.swift (SwiftData-enabled)
import SwiftUI
import SwiftData

struct WorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.modelContext) private var context
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

                            ForEach(0..<workoutManager.workouts.count, id: \.self) { index in
                                let workout = workoutManager.workouts[index]
                                WorkoutRowView(
                                    workout: Binding(get: { workout }, set: { newWorkout in
                                        workoutManager.saveWorkout(newWorkout, context: context)
                                    }),
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
        .onAppear {
            workoutManager.loadWorkouts(context: context)
        }
        .onDisappear {
            currentTimer?.invalidate()
        }
    }

    private var allSetsSuccessful: Bool {
        for workout in workoutManager.workouts {
            for set in workout.sets {
                if set.state != "success" { return false }
            }
        }
        return true
    }

    private func finishWorkout() {
        alertMessage = allSetsSuccessful ? "Workout Success!" : "Workout Failed :("
        showAlert = true
    }

    private func handleSetTap(workoutIndex: Int, setIndex: Int, oldState: SetButton.SetState) {
        var workout = workoutManager.workouts[workoutIndex]
        let set = workout.sets[setIndex]

        switch set.state {
        case "notStarted":
            workout.sets[setIndex].state = "success"
            startTimer(seconds: successRestTime)
        case "success":
            workout.sets[setIndex].state = "failure"
            startTimer(seconds: failureRestTime)
        case "failure":
            workout.sets[setIndex].state = "notStarted"
            startTimer(seconds: notStartedRestTime)
        default:
            workout.sets[setIndex].state = "notStarted"
        }
        workoutManager.saveWorkout(workout, context: context)
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
