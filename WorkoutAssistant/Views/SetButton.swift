//
//  SetButton.swift
//  WorkoutAssistant
//
//  Created by Zac Gerhardy on 7/23/25.
//

import SwiftUI

public enum SetState: Equatable {
    case notStarted(Int)
    case success(Int)
    case failure(Int)
}

public struct SetButton: View {
    @Binding public var state: SetState
    public let onTap: (SetState) -> Void

    private let size: CGFloat = 50
    private let longPressDuration = 2.0

    public init(state: Binding<SetState>, onTap: @escaping (SetState) -> Void) {
        self._state = state
        self.onTap = onTap
    }

    public var body: some View {
        let (label, color): (String, Color) = {
            switch state {
            case .notStarted(let reps): return ("\(reps)", .gray)
            case .success(let reps): return ("\(reps)", .green)
            case .failure(let reps): return ("\(reps)", .red)
            }
        }()

        Text(label)
            .frame(width: size, height: size)
            .background(color)
            .foregroundColor(.white)
            .clipShape(Circle())
            .onTapGesture {
                onTap(state)
            }
            .onLongPressGesture(minimumDuration: longPressDuration) {
                state = .failure(1)
                onTap(state)
            }
    }
}
