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
<<<<<<< HEAD
=======
        // Push behind desktop icons
>>>>>>> 9db167e02c9263e86a3bc5568df9de03a1da5f2b
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

<<<<<<< HEAD
    func playVideo(url: URL, muted: Bool = true, loop: Bool = true) {
        playerLayer?.removeFromSuperlayer()

        player = AVPlayer(url: url)
        player?.isMuted = muted

=======
    func playVideo(url: URL) {
        playerLayer?.removeFromSuperlayer()

        player = AVPlayer(url: url)
>>>>>>> 9db167e02c9263e86a3bc5568df9de03a1da5f2b
        playerLayer = AVPlayerLayer(player: player!)
        playerLayer!.frame = self.contentView!.bounds
        playerLayer!.videoGravity = .resizeAspectFill

        self.contentView?.wantsLayer = true
        self.contentView?.layer?.addSublayer(playerLayer!)

<<<<<<< HEAD
        if loop {
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem,
                queue: .main
            ) { _ in
                self.player?.seek(to: .zero)
                self.player?.play()
            }
=======
        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            self.player?.seek(to: .zero)
            self.player?.play()
>>>>>>> 9db167e02c9263e86a3bc5568df9de03a1da5f2b
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
<<<<<<< HEAD

    func setMuted(_ muted: Bool) {
        player?.isMuted = muted
    }
=======
>>>>>>> 9db167e02c9263e86a3bc5568df9de03a1da5f2b
}
