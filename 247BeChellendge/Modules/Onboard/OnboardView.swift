import SwiftUI

struct OnboardView: View {
    var onEnd: () -> Void
    @State var state: OnboardState = .first
    var isSE: Bool { UIScreen.isIphoneSEClassic }
    
    var body: some View {
        VStack {
            if isSE {
                Image(state.rawValue)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .padding(.top)
            } else {
                Image(state.rawValue)
                    .resizable()
                    .scaledToFit()
            }
            
            Spacer()
            
            Button(action: {
                switch state {
                case .first:
                    state = .second
                case .second:
                    state = .third
                case .third:
                    onEnd()
                }
            }) {
                Image(.nextBtn)
                    .resizable().scaledToFit().padding()
            }
            .padding(.bottom, 50.fitH)
        }
    }
}

enum OnboardState: String, CaseIterable {
    case first, second, third
}
