//
//  ButtonSectionView.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 8/3/25.
//


import SwiftUI

// MARK: - Planner Button Style
struct PlannerButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(6)
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .foregroundColor(.white)
            .cornerRadius(6)
    }
}

struct ButtonSectionView: View {
    var addWorkout: () -> Void
    var saveWorkouts: () -> Void
    var cancelWorkouts: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Button("Add") { addWorkout() }
                .buttonStyle(PlannerButtonStyle(color: .blue))

            Button("Save") { saveWorkouts() }
                .buttonStyle(PlannerButtonStyle(color: .green))

            Button("Cancel") { cancelWorkouts() }
                .buttonStyle(PlannerButtonStyle(color: .red))
        }
    }
}
