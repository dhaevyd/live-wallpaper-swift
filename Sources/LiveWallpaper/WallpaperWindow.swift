import Cocoa
import AVFoundation

class WallpaperWindow: NSWindow {
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var targetScreen: NSScreen

    init(screen: NSScreen) {
        self.targetScreen = screen
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        setupWindow()
    }

    func setupWindow() {
        // Push behind desktop icons
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
        self.ignoresMouseEvents = true
    }

    func playVideo(url: URL) {
        playerLayer?.removeFromSuperlayer()

        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player!)
        playerLayer!.frame = self.contentView!.bounds
        playerLayer!.videoGravity = .resizeAspectFill

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
        player = nil
        self.orderOut(nil)
    }

    func pauseVideo() {
        player?.pause()
    }

    func resumeVideo() {
        player?.play()
    }
}
