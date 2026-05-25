import Cocoa
import AVFoundation
import AVKit

class WallpaperWindow: NSWindow {
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?

    init() {
        // Full screen size
        let screen = NSScreen.main!.frame
        super.init(
            contentRect: screen,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        setupWindow()
    }

    func setupWindow() {
        // Push window behind desktop icons
        self.level = NSWindow.Level(
            rawValue: Int(CGWindowLevelForKey(.desktopWindow))
        )
        self.collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .ignoresCycle
        ]
        self.isOpaque = true
        self.hasShadow = false
        self.backgroundColor = .black
    }

    func playVideo(url: URL) {
        // Remove old player if exists
        playerLayer?.removeFromSuperlayer()

        // Setup AVPlayer
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player!)
        playerLayer!.frame = self.contentView!.bounds
        playerLayer!.videoGravity = .resizeAspectFill

        // Add to window
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.addSublayer(playerLayer!)

        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            self.player?.seek(to: .zero)
            self.player?.play()
        }

        player?.play()
        self.makeKeyAndOrderFront(nil)
    }

    func stopVideo() {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
    }
}
