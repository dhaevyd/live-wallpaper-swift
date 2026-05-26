import SwiftUI

struct WallpaperCard: View {
    let wallpaper: Wallpaper
    var onTap: ((Wallpaper) -> Void)? = nil

    @State private var isHovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .topTrailing) {
            cardImage
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(isHovered ? 0.22 : 0))
                )

            if wallpaper.isPro {
                Text("PRO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.wallflowAccent, in: Capsule())
                    .padding(10)
            }
        }
        .frame(width: 300, height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(isHovered && !reduceMotion ? 1.03 : 1.0)
        .shadow(
            color: .black.opacity(isHovered ? 0.4 : 0.15),
            radius: isHovered ? 16 : 6
        )
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: isHovered)
        .onHover { isHovered = $0 }
        .onTapGesture { onTap?(wallpaper) }
        .contentShape(Rectangle())
    }

    private var cardImage: some View {
        Group {
            if let url = wallpaper.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        cardPlaceholder
                    }
                }
            } else {
                cardPlaceholder
            }
        }
        .frame(width: 300, height: 180)
    }

    private var cardPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "1c1c2e").opacity(0.9),
                    Color.wallflowSurface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 6) {
                Image(systemName: "photo")
                    .font(.system(size: 22, weight: .ultraLight))
                    .foregroundStyle(Color.white.opacity(0.18))
                Text(wallpaper.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.25))
                    .lineLimit(1)
                    .padding(.horizontal, 12)
            }
        }
    }
}
