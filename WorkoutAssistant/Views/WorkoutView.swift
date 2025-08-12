// ===== START FILE: WorkoutView.swift =====
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
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // Access the (single) plan that toggles the run section
    @Query private var plans: [WorkoutPlan]
    private var activePlan: WorkoutPlan? { plans.first }

    // Run UI state
    @State private var ranDistance: Double = 0
    @State private var useDefaultLap: Bool = true
    @State private var lapText: String = ""

    @State private var timerSeconds: Int? = nil
    @State private var currentTimer: Timer? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var localSets: [[LocalSetState]] = []

    @State private var workoutTime: Int = 0
    @State private var workoutTimer: Timer? = nil
    @State private var workoutStartTime: Date = Date()

    // Constants for layout and timer behavior.
    private let successRestTime = 90
    private let failureRestTime = 180
    private let notStartedRestTime = 0

    private let nameWidth: CGFloat = 100
    private let weightWidth: CGFloat = 75
    private let horizontalSpacing: CGFloat = 10
    private let rowSpacing: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            let fixedColumnsWidth: CGFloat = nameWidth + weightWidth // name + weight
            let availableWidth = max(0, geometry.size.width - fixedColumnsWidth - horizontalSpacing * 2 - rowSpacing * 2)
            let columnsCount = max(Int(availableWidth / 60), 1)

            VStack {
                headerSection
                ScrollView {
                    // Run section (only when plan toggle is ON)
                    if let plan = activePlan, plan.includeRunSection {
                        runSection(plan: plan)
                            .padding(.horizontal, horizontalSpacing)
                    }

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

            // 🔧 Ensure there is only one plan row
            if plans.count > 1 {
                for p in plans.dropFirst() { context.delete(p) }
                try? context.save()
            }

            if let plan = activePlan, plan.includeRunSection {
                ranDistance = 0
                useDefaultLap = true
                lapText = formatted(plan.defaultLapDistance)
            }
        }

        .onDisappear {
            currentTimer?.invalidate()
            workoutTimer?.invalidate()
        }
    }

    // MARK: - Header
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

    // MARK: - Run Section
    private func runSection(plan: WorkoutPlan) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Run Goal: \(formatted(plan.runGoalDistance)) \(settings.runUnit.rawValue)")
                .font(.headline)

            HStack(spacing: 12) {
                Text("Ran: \(formatted(ranDistance)) \(settings.runUnit.rawValue)")
                Spacer()
                Button("Clear") {
                    ranDistance = 0
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                Button("Add") {
                    let lap = useDefaultLap ? plan.defaultLapDistance : (Double(lapText) ?? 0)
                    ranDistance += max(0, lap)
                }
                .buttonStyle(.borderedProminent)

                TextField("0", text: $lapText)
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(useDefaultLap)
                    .opacity(useDefaultLap ? 0.5 : 1.0)

                Toggle("Use Default", isOn: $useDefaultLap)
                    .onChange(of: useDefaultLap) { _, nowOn in
                        if nowOn {
                            lapText = formatted(plan.defaultLapDistance)
                        }
                    }
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(Color(UIColor.separator), lineWidth: 0.5)
        )
        .cornerRadius(8)
    }

    // MARK: - Grid (outer rounded only)
    private func buildWorkoutGrid(availableWidth: CGFloat, columnsCount: Int) -> some View {
        let cornerRadius: CGFloat = 12

        return ZStack {
            // Outer rounded border
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color(UIColor.separator), lineWidth: 0.5)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color(UIColor.systemGroupedBackground))
                )

            // Inner content clipped so only outer corners are rounded
            Grid(horizontalSpacing: horizontalSpacing, verticalSpacing: 0) {
                headerRow(availableWidth: availableWidth)
                ForEach(Array(localSets.enumerated()), id: \.offset) { (workoutIndex, _) in
                    buildWorkoutGridRow(workoutIndex: workoutIndex,
                                        availableWidth: availableWidth,
                                        columnsCount: columnsCount)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .padding(.horizontal, horizontalSpacing)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private func headerRow(availableWidth: CGFloat) -> some View {
        GridRow {
            HStack(alignment: .top, spacing: rowSpacing) {
                Text("Workout").bold().frame(width: nameWidth, alignment: .leading)
                Text("\(settings.weightUnit.rawValue)").bold().frame(width: weightWidth, alignment: .leading)
                Text("Sets and Reps").bold().frame(maxWidth: availableWidth, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(UIColor.quaternarySystemFill))
            .overlay(Divider(), alignment: .bottom) // separator
            .gridCellColumns(3)
        }
    }

    private func buildWorkoutGridRow(workoutIndex: Int,
                                     availableWidth: CGFloat,
                                     columnsCount: Int) -> some View {
        let workout = workoutManager.workouts[workoutIndex]
        return GridRow {
            HStack(alignment: .top, spacing: rowSpacing) {
                Text(workout.name).frame(width: nameWidth, alignment: .leading)
                Text("\(workout.weight, format: .number.grouping(.never).precision(.fractionLength(0...6)))")
                    .frame(width: weightWidth, alignment: .leading)
                buildSetButtons(workoutIndex: workoutIndex, availableWidth: availableWidth, columnsCount: columnsCount)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(rowColor(for: workoutIndex))
            .overlay(alignment: .bottom) {
                if workoutIndex != localSets.count - 1 { Divider() } // no divider on the last row
            }
            .gridCellColumns(3)
        }
    }

    private func buildSetButtons(workoutIndex: Int, availableWidth: CGFloat, columnsCount: Int) -> some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(50), spacing: 5), count: columnsCount),
            alignment: .leading,
            spacing: 15
        ) {
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

    // MARK: - Footer bits
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

    // MARK: - Data / Logic
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
        workoutTimer?.invalidate()
        let resultItems = saveWorkoutResult()
        workoutManager.adjustWeightsAfterWorkout(context: context, results: resultItems, settings: settings)
    }

    @discardableResult
    private func saveWorkoutResult() -> [WorkoutResultItem] {
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

        // Combine lift + run success (when run is enabled)
        var overallSuccess = resultItems.allSatisfy { $0.success }
        if let plan = activePlan, plan.includeRunSection {
            let runSuccess = ranDistance >= plan.runGoalDistance
            overallSuccess = overallSuccess && runSuccess
        }

        let result = WorkoutResult(
            timestamp: Date(),
            totalTime: Double(workoutTime),
            workouts: resultItems,
            overallSuccess: overallSuccess
        )

        context.insert(result)
        try? context.save()
        return resultItems
    }

    private func handleSetTap(workoutIndex: Int, setIndex: Int) {
        guard workoutIndex < localSets.count, setIndex < localSets[workoutIndex].count else { return }
        var set = localSets[workoutIndex][setIndex]

        switch set.state {
        case "notStarted":
            set.state = "success"
            startTimer(seconds: successRestTime)
        case "success":
            set.state = "failure"
            if set.reps > 0 {
                set.reps -= 1
            }
            startTimer(seconds: failureRestTime)
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

    // Update the weight directly (currently unused but kept for parity)
    private func updateWeight(_ weight: Double) {
        if let workout = workoutManager.workouts.first {
            workout.weight = weight
        }
    }

    // Reset the set state
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

    private func rowColor(for index: Int) -> Color {
        index.isMultiple(of: 2) ? Color(.secondarySystemGroupedBackground) : Color(.tertiarySystemGroupedBackground)
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(value)
    }
}
// ===== END FILE: WorkoutView.swift =====
