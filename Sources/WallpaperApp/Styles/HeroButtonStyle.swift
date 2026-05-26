import SwiftUI

struct HeroButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.white, in: Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
