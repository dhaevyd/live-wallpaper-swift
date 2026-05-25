import Cocoa
import AVFoundation

class HeroView: NSView {
    var onSetAsWallpaper: ((PexelsVideo) -> Void)?
    var currentVideo: PexelsVideo?

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var imageLayer: CALayer?
    private let gradientLayer = CAGradientLayer()
    private let pulseDot = NSView()
    private let categoryLabel = WallflowTheme.label("FEATURED", size: 10, weight: .bold, color: WallflowTheme.accent, tracking: 2.4)
    private let titleLabel = WallflowTheme.label("", size: 36, weight: .black, color: .white)
    private let metaLabel = WallflowTheme.label("", size: 12, weight: .regular, color: NSColor.white.withAlphaComponent(0.62))
    private let setWallpaperBtn = NSButton(title: "SET WALLPAPER", target: nil, action: nil)
    private let nowPlaying = WallflowTheme.label("NOW PLAYING", size: 9, weight: .bold, color: WallflowTheme.accent, tracking: 2)
    private let badge4k = WallflowTheme.label("4K", size: 10, weight: .bold, color: WallflowTheme.accent, tracking: 1.4)
    private let thumbnailsRow = NSScrollView()
    private let thumbnailsStack = NSStackView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        player?.pause()
        player = nil
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        layer?.cornerRadius = 10
        layer?.masksToBounds = true

        gradientLayer.colors = [
            NSColor.clear.cgColor,
            NSColor.black.withAlphaComponent(0.72).cgColor,
            NSColor.black.withAlphaComponent(0.95).cgColor
        ]
        gradientLayer.locations = [0.0, 0.55, 1.0]
        layer?.addSublayer(gradientLayer)

        pulseDot.translatesAutoresizingMaskIntoConstraints = false
        pulseDot.wantsLayer = true
        pulseDot.layer?.backgroundColor = WallflowTheme.accent.cgColor
        pulseDot.layer?.cornerRadius = 4
        addSubview(pulseDot)
        addSubview(nowPlaying)

        badge4k.alignment = .center
        badge4k.wantsLayer = true
        badge4k.layer?.cornerRadius = 6
        badge4k.layer?.borderWidth = 1
        badge4k.layer?.borderColor = WallflowTheme.accent.cgColor
        badge4k.isHidden = true
        addSubview(badge4k)

        titleLabel.maximumNumberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(categoryLabel)
        addSubview(titleLabel)
        addSubview(metaLabel)

        setWallpaperBtn.translatesAutoresizingMaskIntoConstraints = false
        setWallpaperBtn.target = self
        setWallpaperBtn.action = #selector(setAsWallpaper)
        setWallpaperBtn.isBordered = false
        setWallpaperBtn.font = NSFont.systemFont(ofSize: 9, weight: .heavy)
        setWallpaperBtn.contentTintColor = .black
        setWallpaperBtn.wantsLayer = true
        setWallpaperBtn.layer?.backgroundColor = WallflowTheme.accent.cgColor
        setWallpaperBtn.layer?.cornerRadius = 3
        addSubview(setWallpaperBtn)

        thumbnailsRow.translatesAutoresizingMaskIntoConstraints = false
        thumbnailsRow.drawsBackground = false
        thumbnailsRow.hasHorizontalScroller = false
        thumbnailsRow.hasVerticalScroller = false
        thumbnailsStack.translatesAutoresizingMaskIntoConstraints = false
        thumbnailsStack.orientation = .horizontal
        thumbnailsStack.spacing = 10
        thumbnailsRow.documentView = thumbnailsStack
        addSubview(thumbnailsRow)

        NSLayoutConstraint.activate([
            pulseDot.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            pulseDot.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            pulseDot.widthAnchor.constraint(equalToConstant: 8),
            pulseDot.heightAnchor.constraint(equalToConstant: 8),
            nowPlaying.centerYAnchor.constraint(equalTo: pulseDot.centerYAnchor),
            nowPlaying.leadingAnchor.constraint(equalTo: pulseDot.trailingAnchor, constant: 8),

            badge4k.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            badge4k.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            badge4k.widthAnchor.constraint(equalToConstant: 44),
            badge4k.heightAnchor.constraint(equalToConstant: 24),

            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            categoryLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -160),
            titleLabel.bottomAnchor.constraint(equalTo: metaLabel.topAnchor, constant: -4),
            metaLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            metaLabel.bottomAnchor.constraint(equalTo: setWallpaperBtn.topAnchor, constant: -16),

            setWallpaperBtn.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            setWallpaperBtn.bottomAnchor.constraint(equalTo: thumbnailsRow.topAnchor, constant: -16),
            setWallpaperBtn.widthAnchor.constraint(equalToConstant: 126),
            setWallpaperBtn.heightAnchor.constraint(equalToConstant: 30),

            thumbnailsRow.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            thumbnailsRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            thumbnailsRow.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            thumbnailsRow.heightAnchor.constraint(equalToConstant: 68),
            thumbnailsStack.leadingAnchor.constraint(equalTo: thumbnailsRow.contentView.leadingAnchor),
            thumbnailsStack.topAnchor.constraint(equalTo: thumbnailsRow.contentView.topAnchor),
            thumbnailsStack.bottomAnchor.constraint(equalTo: thumbnailsRow.contentView.bottomAnchor),
            thumbnailsStack.heightAnchor.constraint(equalTo: thumbnailsRow.heightAnchor)
        ])
    }

    func configure(with video: PexelsVideo, related: [PexelsVideo]) {
        currentVideo = video
        titleLabel.stringValue = video.title.uppercased()
        metaLabel.stringValue = "\(video.width)x\(video.height)  /  \(video.duration)s  /  \(video.user.name)"
        badge4k.isHidden = video.width < 3840

        if let url = URL(string: video.image) {
            ImageCache.shared.image(for: url) { image in
                guard self.currentVideo?.id == video.id, let image = image else { return }
                self.showThumbnailBackground(image: image)
            }
        }

        if let link = video.bestVideoFile?.link, let url = URL(string: link) {
            startPlayer(url: url)
        }
        populateThumbnails(videos: related)
    }

    func suspendPlayback() {
        player?.rate = 0
    }

    func resumePlayback() {
        if currentVideo != nil {
            player?.play()
        }
    }

    private func startPlayer(url: URL) {
        if player == nil {
            player = AVPlayer(url: url)
            player?.isMuted = true
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            if let playerLayer = playerLayer {
                layer?.insertSublayer(playerLayer, at: 0)
            }
        } else {
            player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
        player?.isMuted = true
        player?.play()
    }

    private func showThumbnailBackground(image: NSImage) {
        imageLayer?.removeFromSuperlayer()
        let layer = CALayer()
        layer.contents = image
        layer.contentsGravity = .resizeAspectFill
        self.imageLayer = layer
        self.layer?.insertSublayer(layer, at: 0)
        if let playerLayer = playerLayer {
            self.layer?.insertSublayer(playerLayer, above: layer)
        }
        needsLayout = true
    }

    private func populateThumbnails(videos: [PexelsVideo]) {
        thumbnailsStack.arrangedSubviews.forEach { view in
            thumbnailsStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for video in videos.prefix(8) {
            let thumb = MiniThumbnail()
            thumb.configure(with: video)
            thumbnailsStack.addArrangedSubview(thumb)
            NSLayoutConstraint.activate([
                thumb.widthAnchor.constraint(equalToConstant: 108),
                thumb.heightAnchor.constraint(equalToConstant: 64)
            ])
        }
    }

    @objc private func setAsWallpaper() {
        guard let video = currentVideo else { return }
        onSetAsWallpaper?(video)
    }

    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        imageLayer?.frame = bounds
        playerLayer?.frame = bounds
        gradientLayer.frame = bounds
        CATransaction.commit()
    }
}

class MiniThumbnail: NSView {
    private let imageView = NSImageView()
    private var imageURL: URL?

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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.imageScaling = .scaleAxesIndependently
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(with video: PexelsVideo) {
        guard let url = URL(string: video.image) else { return }
        imageURL = url
        ImageCache.shared.image(for: url) { image in
            guard self.imageURL == url else { return }
            self.imageView.image = image
        }
    }
}
