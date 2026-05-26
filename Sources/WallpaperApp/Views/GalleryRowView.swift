import SwiftUI

struct GalleryRowView: View {
    let title: String
    let subtitle: String
    let wallpapers: [Wallpaper]
    var onCardTap: ((Wallpaper) -> Void)? = nil
    var onSeeAll: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            rowHeader
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(wallpapers) { wallpaper in
                        WallpaperCard(wallpaper: wallpaper) { tapped in
                            onCardTap?(tapped)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }

    private var rowHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onSeeAll?()
            } label: {
                HStack(spacing: 4) {
                    Text("See all")
                        .font(.system(size: 12))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(Color.wallflowAccent)
            }
            .buttonStyle(.plain)
        }
    }
}
