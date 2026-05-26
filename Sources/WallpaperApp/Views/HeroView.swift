import SwiftUI
import AVFoundation

struct HeroView: View {
    let featured: Wallpaper
    let thumbnails: [Wallpaper]
    var isLoading: Bool = false
    var onViewWallpaper: ((Wallpaper) -> Void)? = nil

    @State private var displayed: Wallpaper
    @State private var player: AVPlayer? = nil
    @State private var isFavourite = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        featured: Wallpaper,
        thumbnails: [Wallpaper],
        isLoading: Bool = false,
        onViewWallpaper: ((Wallpaper) -> Void)? = nil
    ) {
        self.featured = featured
        self.thumbnails = thumbnails
        self.isLoading = isLoading
        self.onViewWallpaper = onViewWallpaper
        self._displayed = State(initialValue: featured)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            heroBackground

            LinearGradient(
                colors: [.clear, .black.opacity(0.82)],
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
        .onAppear { setupPlayer(for: featured) }
        .onChange(of: featured) { newFeatured in
            displayed = newFeatured
            setupPlayer(for: newFeatured)
        }
        .onDisappear { player?.pause() }
    }

    // MARK: - Background

    private var heroBackground: some View {
        ZStack {
            // Poster image — visible while video buffers or if no video URL
            Group {
                if let url = displayed.imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: backgroundPlaceholder
                        }
                    }
                } else {
                    backgroundPlaceholder
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Cinematic video layer
            if let player {
                VideoPlayerView(player: player)
                    .transition(reduceMotion ? .identity : .opacity.animation(.easeIn(duration: 0.6)))
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

    // MARK: - Thumbnail strip — tapping selects which video plays in the hero

    private var thumbnailStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(thumbnails) { thumb in
                    ThumbnailCard(
                        wallpaper: thumb,
                        isSelected: displayed.id == thumb.id
                    ) {
                        selectThumbnail(thumb)
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

    // MARK: - Info overlay

    private var heroInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("FEATURED")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
                .tracking(1.5)

            Text(displayed.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: displayed.id)

            Text(displayed.metaLine)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 10) {
                Button("View Wallpaper") {
                    onViewWallpaper?(displayed)
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
                .accessibilityLabel(isFavourite ? "Remove from favourites" : "Add to favourites")
            }
            .padding(.top, 4)
        }
        .padding(28)
    }

    // MARK: - Helpers

    private func selectThumbnail(_ wallpaper: Wallpaper) {
        guard wallpaper.id != displayed.id else { return }
        displayed = wallpaper
        setupPlayer(for: wallpaper)
    }

    private func setupPlayer(for wallpaper: Wallpaper) {
        player?.pause()
        player = nil
        guard let url = wallpaper.videoURL else { return }
        let p = AVPlayer(url: url)
        p.isMuted = true
        p.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: p.currentItem,
            queue: .main
        ) { _ in p.seek(to: .zero); p.play() }
        p.play()
        player = p
    }
}
