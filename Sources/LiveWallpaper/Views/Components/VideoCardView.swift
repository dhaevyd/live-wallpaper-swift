import Cocoa
import AVFoundation

class VideoCardView: NSView {
    var video: PexelsVideo?
    var onSelect: ((PexelsVideo) -> Void)?

    private var previewPlayer: AVPlayer?
    private var previewLayer: AVPlayerLayer?
    private var previewWorkItem: DispatchWorkItem?
    private var imageURL: URL?
    private let imageView = NSImageView()
    private let gradientLayer = CAGradientLayer()
    private let titleLabel = WallflowTheme.label("", size: 11, weight: .semibold, color: .white)
    private let durationLabel = WallflowTheme.label("", size: 10, weight: .bold, color: .white)
    private let downloadedBadge = NSView()
    private let activeStripe = NSView()
    private var trackingAreaRef: NSTrackingArea?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.masksToBounds = true
        layer?.backgroundColor = WallflowTheme.surface.cgColor
        layer?.borderWidth = 1
        layer?.borderColor = WallflowTheme.border.cgColor

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.wantsLayer = true
        imageView.imageScaling = .scaleAxesIndependently
        addSubview(imageView)

        gradientLayer.colors = [NSColor.clear.cgColor, NSColor.black.withAlphaComponent(0.72).cgColor]
        gradientLayer.locations = [0.35, 1.0]
        layer?.addSublayer(gradientLayer)

        titleLabel.lineBreakMode = .byTruncatingTail
        durationLabel.alignment = .right
        addSubview(titleLabel)
        addSubview(durationLabel)

        downloadedBadge.translatesAutoresizingMaskIntoConstraints = false
        downloadedBadge.wantsLayer = true
        downloadedBadge.layer?.backgroundColor = WallflowTheme.success.cgColor
        downloadedBadge.layer?.cornerRadius = 4
        downloadedBadge.isHidden = true
        addSubview(downloadedBadge)

        activeStripe.translatesAutoresizingMaskIntoConstraints = false
        activeStripe.wantsLayer = true
        activeStripe.layer?.backgroundColor = WallflowTheme.accent.cgColor
        activeStripe.isHidden = true
        addSubview(activeStripe)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            durationLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            durationLabel.widthAnchor.constraint(equalToConstant: 34),
            downloadedBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            downloadedBadge.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            downloadedBadge.widthAnchor.constraint(equalToConstant: 8),
            downloadedBadge.heightAnchor.constraint(equalToConstant: 8),
            activeStripe.leadingAnchor.constraint(equalTo: leadingAnchor),
            activeStripe.topAnchor.constraint(equalTo: topAnchor),
            activeStripe.bottomAnchor.constraint(equalTo: bottomAnchor),
            activeStripe.widthAnchor.constraint(equalToConstant: 3)
        ])
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingAreaRef = trackingAreaRef {
            removeTrackingArea(trackingAreaRef)
        }
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        trackingAreaRef = area
        addTrackingArea(area)
    }

    func configure(with video: PexelsVideo, isCurrent: Bool = false) {
        self.video = video
        titleLabel.stringValue = video.title
        durationLabel.stringValue = "\(video.duration)s"
        downloadedBadge.isHidden = !VideoDownloader.shared.isDownloaded(video: video)
        activeStripe.isHidden = !isCurrent
        layer?.backgroundColor = isCurrent ? WallflowTheme.accent.withAlphaComponent(0.16).cgColor : WallflowTheme.surface.cgColor

        if let url = URL(string: video.image) {
            imageURL = url
            ImageCache.shared.image(for: url) { image in
                guard self.imageURL == url else { return }
                self.imageView.image = image
            }
        }
    }

    override func mouseEntered(with event: NSEvent) {
        layer?.borderColor = WallflowTheme.accent.withAlphaComponent(0.45).cgColor
        previewWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.startPreview()
        }
        previewWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: item)
    }

    override func mouseExited(with event: NSEvent) {
        previewWorkItem?.cancel()
        previewWorkItem = nil
        stopPreview()
        layer?.borderColor = WallflowTheme.border.cgColor
    }

    override func mouseDown(with event: NSEvent) {
        guard let video = video else { return }
        onSelect?(video)
    }

    func startPreview() {
        guard previewPlayer == nil,
              let video = video,
              let fileURL = URL(string: video.bestVideoFile?.link ?? "")
        else { return }

        imageView.isHidden = true
        let player = AVPlayer(url: fileURL)
        player.isMuted = true
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        self.previewPlayer = player
        self.previewLayer = layer
        self.layer?.insertSublayer(layer, at: 1)
        needsLayout = true
        player.play()
    }

    func stopPreview() {
        previewPlayer?.pause()
        previewLayer?.removeFromSuperlayer()
        previewPlayer = nil
        previewLayer = nil
        imageView.isHidden = false
    }

    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        previewLayer?.frame = bounds
        CATransaction.commit()
    }
}
