// UI component for individual set buttons.
import SwiftUI

struct Constants {
    static let successRestTime = 90
    static let failureRestTime = 180
    static let notStartedRestTime = 0
    static let setButtonSize: CGFloat = 50
    static let longPressDuration = 2.0
}

public struct SetButton: View {
    public enum SetState {
        case notStarted(Int)
        case success(Int)
        case failure(Int)
    }

    @Binding var state: SetState
    let onTap: (SetState) -> Void

    public var body: some View {
        let (label, color): (String, Color) = {
            switch state {
            case .notStarted(let reps): return ("\(reps)", .gray)
            case .success(let reps): return ("\(reps)", .green)
            case .failure(let reps): return ("\(reps)", .red)
            }
        }()

        Text(label)
            .frame(width: Constants.setButtonSize, height: Constants.setButtonSize)
            .background(color)
            .foregroundColor(.white)
            .clipShape(Circle())
            .onTapGesture { onTap(state) }
            .onLongPressGesture(minimumDuration: Constants.longPressDuration) {
                state = .failure(1)
                onTap(state)
            }
    }
}
