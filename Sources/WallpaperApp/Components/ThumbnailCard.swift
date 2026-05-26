import SwiftUI

struct ThumbnailCard: View {
    let wallpaper: Wallpaper
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    @State private var hovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if let url = wallpaper.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(width: 120, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    isSelected ? Color.wallflowAccent : .white.opacity(hovered ? 0.65 : 0.2),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .shadow(
            color: isSelected ? Color.wallflowAccent.opacity(0.4) : .black.opacity(hovered ? 0.5 : 0.2),
            radius: isSelected ? 12 : (hovered ? 10 : 4)
        )
        .scaleEffect(hovered && !reduceMotion ? 1.04 : 1.0)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.16), value: hovered)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isSelected)
        .onHover { hovered = $0 }
        .onTapGesture { onTap?() }
        .contentShape(Rectangle())
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color.wallflowSurface)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.white.opacity(0.15))
            )
    }
}
