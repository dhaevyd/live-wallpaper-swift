import SwiftUI
import AVFoundation

struct VideoPlayerView: NSViewRepresentable {
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

        override init(frame: NSRect) {
            super.init(frame: frame)
            wantsLayer = true
        }

        required init?(coder: NSCoder) { fatalError("not used") }

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
