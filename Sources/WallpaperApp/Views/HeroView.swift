import SwiftUI

struct HeroView: View {
    let featured: Wallpaper
    let thumbnails: [Wallpaper]
    var isLoading: Bool = false
    var onViewWallpaper: ((Wallpaper) -> Void)? = nil
    var onThumbnailTap: ((Wallpaper) -> Void)? = nil

    @State private var isFavourite = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            heroBackground

            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )

            thumbnailStrip

            heroInfo

            if isLoading {
                Color.black.opacity(0.45)
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.wallflowAccent)
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 500)
        .clipped()
    }

    // MARK: - Background

    private var heroBackground: some View {
        Group {
            if let url = featured.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        backgroundPlaceholder
                    }
                }
            } else {
                backgroundPlaceholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var backgroundPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "0c0c0c")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 72, weight: .ultraLight))
                .foregroundStyle(Color.wallflowAccent.opacity(0.18))
        }
    }

    // MARK: - Thumbnail strip (top-right)

    private var thumbnailStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(thumbnails) { thumb in
                    ThumbnailCard(wallpaper: thumb) {
                        onThumbnailTap?(thumb)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 20)
        .padding(.bottom, 106)
    }

    // MARK: - Title / meta / buttons

    private var heroInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FEATURED")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
                .tracking(1.5)

            Text(featured.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)

            Text(featured.metaLine)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 10) {
                Button("View Wallpaper") {
                    onViewWallpaper?(featured)
                }
                .buttonStyle(HeroButtonStyle())

                Button {
                    isFavourite.toggle()
                } label: {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(28)
    }
}
