import SwiftUI
import SwiftData

// Represents the local state for each set button in the current session.
struct LocalSetState: Identifiable, Hashable {
    let id = UUID()
    var reps: Int
    var state: String // Possible values: notStarted, success, failure
}

struct WorkoutView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var timerSeconds: Int? = nil
    @State private var currentTimer: Timer? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var localSets: [[LocalSetState]] = []

    @State private var workoutTime: Int = 0 // Total workout time (in seconds)
    @State private var workoutTimer: Timer? = nil
    @State private var workoutStartTime: Date = Date()

    // Constants for layout and timer behavior.
    private let successRestTime = 90
    private let failureRestTime = 180
    private let notStartedRestTime = 0
    private let columnWidths: [CGFloat] = [75, 75]
    private let verticalSpacing: CGFloat = 15
    private let horizontalSpacing: CGFloat = 5
    private let setButtonSize: CGFloat = 50

    var body: some View {
        GeometryReader { geometry in
            let totalHorizontalPadding: CGFloat = 32
            let availableWidth = max(0, geometry.size.width - columnWidths[0] - columnWidths[1] - totalHorizontalPadding)
            let columnsCount = max(Int(availableWidth / (setButtonSize + horizontalSpacing)), 1)

            VStack {
                headerSection
                ScrollView {
                    buildWorkoutGrid(availableWidth: availableWidth, columnsCount: columnsCount)
                    restTimerView
                    workoutTimeView
                }
                finishButton
            }
        }
        .onAppear {
            loadWorkouts()
            startWorkoutTimer()
        }
        .onDisappear {
            currentTimer?.invalidate()
            workoutTimer?.invalidate()
        }
    }

    // MARK: - UI Sections

    private var headerSection: some View {
        VStack(spacing: 5) {
            Text("Today's Workout!")
                .font(.largeTitle)
                .bold()
            Text(Date.now, style: .date)
                .font(.title3)
                .foregroundColor(.gray)
        }
        .padding(.top)
    }

    private func buildWorkoutGrid(availableWidth: CGFloat, columnsCount: Int) -> some View {
        Grid(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
            GridRow {
                Text("Workout").bold().frame(width: columnWidths[0], alignment: .center)
                Text("Weight").bold().frame(width: columnWidths[1], alignment: .center)
                Text("Sets and Reps").bold().frame(maxWidth: availableWidth, alignment: .leading)
            }

            ForEach(localSets.indices, id: \.self) { workoutIndex in
                let workout = workoutManager.workouts[workoutIndex]
                GridRow {
                    Text(workout.name).frame(width: columnWidths[0], alignment: .center)
                    Text("\(Int(workout.weight))").frame(width: columnWidths[1], alignment: .center)

                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(setButtonSize), spacing: horizontalSpacing), count: columnsCount), alignment: .leading, spacing: verticalSpacing) {
                        ForEach(localSets[workoutIndex].indices, id: \.self) { setIndex in
                            let setBinding = Binding<LocalSetState>(
                                get: { localSets[workoutIndex][setIndex] },
                                set: { localSets[workoutIndex][setIndex] = $0 }
                            )
                            SetButton(
                                state: Binding(
                                    get: { convertToSetState(setBinding.wrappedValue) },
                                    set: { newState in setBinding.wrappedValue = convertFromSetState(newState) }
                                )
                            ) { _ in
                                handleSetTap(workoutIndex: workoutIndex, setIndex: setIndex)
                            }
                        }
                    }
                    .frame(maxWidth: availableWidth, alignment: .leading)
                }
            }
        }
        .padding(.horizontal)
    }

    private var restTimerView: some View {
        Group {
            if let seconds = timerSeconds {
                Text("Rest Timer: \(seconds / 60):\(String(format: "%02d", seconds % 60))")
                    .font(.title2)
                    .padding(.top, 20)
            } else {
                Text("Rest Timer: 0:00")
                    .font(.title2)
                    .padding(.top, 20)
            }
        }
    }

    private var workoutTimeView: some View {
        Text("Workout Time: \(workoutTime / 60):\(String(format: "%02d", workoutTime % 60))")
            .font(.title2)
            .padding(.top, 5)
    }

    private var finishButton: some View {
        Button(action: {
            finishWorkout()
            dismiss()
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
    }

    // MARK: - Data & Logic

    private func loadWorkouts() {
        workoutManager.loadWorkouts(context: context)
        localSets = workoutManager.workouts.map { workout in
            (0..<workout.sets.count).map { _ in LocalSetState(reps: workout.initialReps, state: "notStarted") }
        }
    }

    private func startWorkoutTimer() {
        workoutStartTime = Date()
        workoutTimer?.invalidate()
        workoutTime = 0
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            workoutTime = Int(Date().timeIntervalSince(workoutStartTime))
        }
    }

    private var allSetsSuccessful: Bool {
        localSets.allSatisfy { $0.allSatisfy { $0.state == "success" } }
    }

    private func finishWorkout() {
        alertMessage = allSetsSuccessful ? "Workout Success!" : "Workout Failed :("
        showAlert = true
        workoutTimer?.invalidate()
        saveWorkoutResult()
        

    }

    private func saveWorkoutResult() {
        print("Saving WorkoutResult with \(workoutManager.workouts.count) workouts.")
        print("Overall success: \(allSetsSuccessful)")
        let resultItems: [WorkoutResultItem] = zip(workoutManager.workouts, localSets).map { workout, sets in
            let failedReps = sets.filter { $0.state != "success" }.map { $0.reps }
            let success = failedReps.isEmpty
            return WorkoutResultItem(
                id: workout.id,
                name: workout.name,
                weight: workout.weight,
                success: success,
                failedReps: failedReps
            )
        }

        let overallSuccess = resultItems.allSatisfy { $0.success }

        let result = WorkoutResult(
            timestamp: Date(),
            totalTime: Double(workoutTime),
            workouts: resultItems,
            overallSuccess: overallSuccess
        )

        context.insert(result)
        try? context.save()
    }

    // Handle set button tap logic.
    private func handleSetTap(workoutIndex: Int, setIndex: Int) {
        guard workoutIndex < localSets.count, setIndex < localSets[workoutIndex].count else { return }
        var set = localSets[workoutIndex][setIndex]
        switch set.state {
        case "notStarted":
            set.state = "success"
            startTimer(seconds: successRestTime)
        case "success":
            if set.reps > 0 {
                set.reps -= 1
                set.state = "failure"
                startTimer(seconds: failureRestTime)
            } else {
                resetSet(&set, workoutIndex: workoutIndex)
            }
        case "failure":
            if set.reps > 0 {
                set.reps -= 1
                startTimer(seconds: failureRestTime)
            } else {
                resetSet(&set, workoutIndex: workoutIndex)
            }
        default:
            resetSet(&set, workoutIndex: workoutIndex)
        }
        localSets[workoutIndex][setIndex] = set
    }

    private func resetSet(_ set: inout LocalSetState, workoutIndex: Int) {
        set.state = "notStarted"
        set.reps = workoutManager.workouts[workoutIndex].initialReps
        startTimer(seconds: notStartedRestTime)
    }

    private func convertToSetState(_ set: LocalSetState) -> SetButton.SetState {
        switch set.state {
        case "success": return .success(set.reps)
        case "failure": return .failure(set.reps)
        default: return .notStarted(set.reps)
        }
    }

    private func convertFromSetState(_ state: SetButton.SetState) -> LocalSetState {
        switch state {
        case .success(let reps): return LocalSetState(reps: reps, state: "success")
        case .failure(let reps): return LocalSetState(reps: reps, state: "failure")
        case .notStarted(let reps): return LocalSetState(reps: reps, state: "notStarted")
        }
    }

    private func startTimer(seconds: Int) {
        currentTimer?.invalidate()
        timerSeconds = seconds
        currentTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let time = timerSeconds, time > 0 {
                timerSeconds = time - 1
            } else {
                currentTimer?.invalidate()
                timerSeconds = nil
            }
        }
    }
}
