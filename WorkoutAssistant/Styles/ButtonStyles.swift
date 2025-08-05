//
//  PlannerButtonStyle.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 8/5/25.
//


import SwiftUI

// MARK: - Shared Button Styles

/// Planner / generic button style
struct PlannerButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1.0))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
