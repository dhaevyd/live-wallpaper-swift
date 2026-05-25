import Cocoa
import AVFoundation

class VideoCardView: NSView {
    var video: PexelsVideo?
    var onSelect: ((PexelsVideo) -> Void)?
    var previewPlayer: AVPlayer?
    var previewLayer: AVPlayerLayer?
    var imageView: NSImageView!
    var titleLabel: NSTextField!
    var durationLabel: NSTextField!
    var downloadedBadge: NSView!

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        wantsLayer = true
        layer?.cornerRadius = 12
        layer?.masksToBounds = true
        layer?.backgroundColor = NSColor.white
            .withAlphaComponent(0.05).cgColor

        // Thumbnail
        imageView = NSImageView(
            frame: NSRect(x: 0, y: 25, width: bounds.width, height: bounds.height - 25)
        )
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.wantsLayer = true
        addSubview(imageView)

        // Title
        titleLabel = NSTextField(labelWithString: "")
        titleLabel.font = NSFont.systemFont(ofSize: 11)
        titleLabel.textColor = .white
        titleLabel.frame = NSRect(x: 8, y: 4, width: bounds.width - 50, height: 18)
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)

        // Duration badge
        durationLabel = NSTextField(labelWithString: "")
        durationLabel.font = NSFont.systemFont(ofSize: 10, weight: .medium)
        durationLabel.textColor = .white
        durationLabel.frame = NSRect(
            x: bounds.width - 45,
            y: bounds.height - 28,
            width: 40,
            height: 18
        )
        durationLabel.alignment = .center
        durationLabel.wantsLayer = true
        durationLabel.layer?.backgroundColor = NSColor.black
            .withAlphaComponent(0.6).cgColor
        durationLabel.layer?.cornerRadius = 4
        addSubview(durationLabel)

        // Downloaded badge
        downloadedBadge = NSView(
            frame: NSRect(x: 8, y: bounds.height - 28, width: 20, height: 20)
        )
        downloadedBadge.wantsLayer = true
        downloadedBadge.layer?.backgroundColor = NSColor.systemGreen
            .withAlphaComponent(0.8).cgColor
        downloadedBadge.layer?.cornerRadius = 10
        downloadedBadge.isHidden = true
        addSubview(downloadedBadge)

        // Hover tracking
        let tracking = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(tracking)
    }

    func configure(with video: PexelsVideo) {
        self.video = video
        titleLabel.stringValue = video.title
        durationLabel.stringValue = "\(video.duration)s"
        downloadedBadge.isHidden = !VideoDownloader.shared.isDownloaded(
            video: video
        )

        // Load thumbnail
        if let url = URL(string: video.image) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = NSImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }.resume()
        }
    }

    override func mouseEntered(with event: NSEvent) {
        startPreview()
        layer?.borderWidth = 2
        layer?.borderColor = NSColor.white.cgColor
    }

    override func mouseExited(with event: NSEvent) {
        stopPreview()
        layer?.borderWidth = 0
    }

    override func mouseDown(with event: NSEvent) {
        guard let video = video else { return }
        onSelect?(video)
    }

    func startPreview() {
        guard let video = video,
              let fileURL = URL(string: video.bestVideoFile?.link ?? "")
        else { return }

        imageView.isHidden = true
        previewPlayer = AVPlayer(url: fileURL)
        previewLayer = AVPlayerLayer(player: previewPlayer!)
        previewLayer!.frame = NSRect(
            x: 0, y: 25,
            width: bounds.width,
            height: bounds.height - 25
        )
        previewLayer!.videoGravity = .resizeAspectFill
        layer?.insertSublayer(previewLayer!, at: 0)
        previewPlayer?.play()
    }

    func stopPreview() {
        previewPlayer?.pause()
        previewLayer?.removeFromSuperlayer()
        previewPlayer = nil
        previewLayer = nil
        imageView.isHidden = false
    }
}
