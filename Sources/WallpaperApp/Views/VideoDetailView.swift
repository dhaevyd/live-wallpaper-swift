import SwiftUI
import AVFoundation

struct VideoDetailView: View {
    let wallpaper: Wallpaper
    var onDismiss: () -> Void

    @StateObject private var download = DownloadState()
    @State private var player: AVPlayer? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Video or poster background
            Group {
                if let player {
                    VideoPlayerView(player: player)
                } else {
                    AsyncImage(url: wallpaper.imageURL) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: Color.wallflowBackground
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Back button
            VStack {
                HStack {
                    Button { onDismiss() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                Spacer()
            }

            // Bottom controls
            VStack(alignment: .leading, spacing: 12) {
                Spacer()

                Text(wallpaper.title.uppercased())
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(wallpaper.metaLine)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button("SET AS WALLPAPER") {}
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.wallflowAccent, in: Capsule())
                        .buttonStyle(.plain)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())

                    Button(download.isDownloaded ? "DOWNLOADED" : "DOWNLOAD") {
                        guard let url = wallpaper.videoURL else { return }
                        download.start(url: url, id: wallpaper.id)
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(download.isDownloaded ? Color.wallflowAccent : .white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().strokeBorder(
                            download.isDownloaded ? Color.wallflowAccent : .white.opacity(0.4),
                            lineWidth: 1
                        )
                    )
                    .buttonStyle(.plain)
                    .disabled(download.isDownloading || download.isDownloaded)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }

                if download.isDownloading || !download.status.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        if download.isDownloading {
                            ProgressView(value: download.progress)
                                .progressViewStyle(.linear)
                                .tint(Color.wallflowAccent)
                                .frame(maxWidth: 300)
                        }
                        if !download.status.isEmpty {
                            Text(download.status)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: download.isDownloading)
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.wallflowBackground)
        .onAppear {
            setupPlayer()
            download.checkDownloaded(id: wallpaper.id)
        }
        .onDisappear { player?.pause() }
    }

    private func setupPlayer() {
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

// MARK: - Download state

@MainActor
private final class DownloadState: ObservableObject {
    @Published var progress: Double = 0
    @Published var isDownloading = false
    @Published var status = ""
    @Published var isDownloaded = false

    private var observer: NSKeyValueObservation?

    func checkDownloaded(id: Int) {
        let dest = VideoDownloader.shared.downloadFolder.appendingPathComponent("\(id).mp4")
        isDownloaded = FileManager.default.fileExists(atPath: dest.path)
    }

    func start(url: URL, id: Int) {
        guard !isDownloading, !isDownloaded else { return }
        isDownloading = true
        status = "Downloading…"
        progress = 0

        let dest = VideoDownloader.shared.downloadFolder.appendingPathComponent("\(id).mp4")

        if FileManager.default.fileExists(atPath: dest.path) {
            isDownloading = false
            isDownloaded = true
            status = "Already downloaded"
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, _, error in
            DispatchQueue.main.async {
                self?.observer = nil
                self?.isDownloading = false
                if let error {
                    self?.status = error.localizedDescription
                    return
                }
                guard let tempURL else { return }
                do {
                    if FileManager.default.fileExists(atPath: dest.path) {
                        try FileManager.default.removeItem(at: dest)
                    }
                    try FileManager.default.moveItem(at: tempURL, to: dest)
                    self?.isDownloaded = true
                    self?.status = "Saved to ~/Movies/LiveWallpapers"
                } catch {
                    self?.status = error.localizedDescription
                }
            }
        }

        observer = task.progress.observe(\.fractionCompleted, options: [.new]) { [weak self] p, _ in
            DispatchQueue.main.async { self?.progress = p.fractionCompleted }
        }
        task.resume()
    }
}

// MARK: - AVPlayer NSViewRepresentable

private struct VideoPlayerView: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> PlayerNSView {
        let view = PlayerNSView()
        view.player = player
        return view
    }

    func updateNSView(_ view: PlayerNSView, context: Context) {
        view.player = player
    }

    final class PlayerNSView: NSView {
        var player: AVPlayer? {
            didSet { playerLayer.player = player }
        }

        override func makeBackingLayer() -> CALayer { AVPlayerLayer() }
        override var wantsUpdateLayer: Bool { true }

        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

        override func layout() {
            super.layout()
            playerLayer.frame = bounds
            playerLayer.videoGravity = .resizeAspectFill
        }
    }
}
