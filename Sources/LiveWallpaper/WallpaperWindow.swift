import Cocoa
import AVFoundation

final class WallpaperWindow: NSWindow {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var loopObserver: (any NSObjectProtocol)?

    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        isOpaque = true
        hasShadow = false
        backgroundColor = .black
        ignoresMouseEvents = true
    }

    func playVideo(url: URL) {
        stopVideo()
        let p = AVPlayer(url: url)
        p.isMuted = true
        p.actionAtItemEnd = .none

        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: p.currentItem,
            queue: .main
        ) { [weak p] _ in p?.seek(to: .zero); p?.play() }

        let layer = AVPlayerLayer(player: p)
        layer.frame = contentView!.bounds
        layer.videoGravity = .resizeAspectFill
        contentView?.wantsLayer = true
        contentView?.layer?.addSublayer(layer)

        p.play()
        makeKeyAndOrderFront(nil)
        player = p
        playerLayer = layer
    }

    func stopVideo() {
        player?.pause()
        if let obs = loopObserver {
            NotificationCenter.default.removeObserver(obs)
            loopObserver = nil
        }
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        orderOut(nil)
    }
}
