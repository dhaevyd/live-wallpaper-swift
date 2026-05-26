import SwiftUI

struct NavPillStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? Color.black : Color.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(isSelected ? Color.white : Color.clear, in: Capsule())
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
