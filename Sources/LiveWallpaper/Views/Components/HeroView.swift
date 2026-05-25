import Cocoa
import AVFoundation

class HeroView: NSView {
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var gradientLayer: CAGradientLayer?
    var onSetAsWallpaper: ((PexelsVideo) -> Void)?
    var currentVideo: PexelsVideo?

    // UI Elements
    var categoryLabel: NSTextField!
    var titleLabel: NSTextField!
    var metaLabel: NSTextField!
    var setWallpaperBtn: NSButton!
    var thumbnailsRow: NSScrollView!
    var thumbnailsContainer: NSView!

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor

        // Gradient overlay
        gradientLayer = CAGradientLayer()
        gradientLayer!.frame = bounds
        gradientLayer!.colors = [
            NSColor.clear.cgColor,
            NSColor.black.withAlphaComponent(0.3).cgColor,
            NSColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer!.locations = [0.0, 0.5, 1.0]
        layer?.addSublayer(gradientLayer!)

        // Category label
        categoryLabel = NSTextField(labelWithString: "FEATURED")
        categoryLabel.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        categoryLabel.textColor = NSColor.white.withAlphaComponent(0.8)
        categoryLabel.frame = NSRect(x: 40, y: 220, width: 200, height: 20)
        addSubview(categoryLabel)

        // Title label
        titleLabel = NSTextField(labelWithString: "")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = .white
        titleLabel.frame = NSRect(x: 40, y: 170, width: 600, height: 45)
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)

        // Meta label
        metaLabel = NSTextField(labelWithString: "")
        metaLabel.font = NSFont.systemFont(ofSize: 12)
        metaLabel.textColor = NSColor.white.withAlphaComponent(0.7)
        metaLabel.frame = NSRect(x: 40, y: 148, width: 400, height: 20)
        addSubview(metaLabel)

        // Set as wallpaper button
        setWallpaperBtn = NSButton(
            title: "Set as Wallpaper  ↗",
            target: self,
            action: #selector(setAsWallpaper)
        )
        setWallpaperBtn.frame = NSRect(x: 40, y: 100, width: 180, height: 36)
        setWallpaperBtn.wantsLayer = true
        setWallpaperBtn.layer?.backgroundColor = NSColor.white
            .withAlphaComponent(0.2).cgColor
        setWallpaperBtn.layer?.cornerRadius = 18
        setWallpaperBtn.isBordered = false
        setWallpaperBtn.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        setWallpaperBtn.contentTintColor = .white
        addSubview(setWallpaperBtn)

        // Thumbnails row
        setupThumbnailsRow()
    }

    func setupThumbnailsRow() {
        thumbnailsContainer = NSView(
            frame: NSRect(x: 0, y: 10, width: 2000, height: 80)
        )

        thumbnailsRow = NSScrollView(
            frame: NSRect(x: 40, y: 10, width: bounds.width - 80, height: 80)
        )
        thumbnailsRow.documentView = thumbnailsContainer
        thumbnailsRow.hasHorizontalScroller = false
        thumbnailsRow.drawsBackground = false
        addSubview(thumbnailsRow)
    }

    func configure(with video: PexelsVideo, related: [PexelsVideo]) {
        currentVideo = video
        titleLabel.stringValue = video.title
        metaLabel.stringValue = "\(video.width)x\(video.height)  •  \(video.duration)s"

        // Load thumbnail image
        if let url = URL(string: video.image) {
            loadImage(url: url) { image in
                self.showThumbnailBackground(image: image)
            }
        }

        // Populate thumbnails row
        populateThumbnails(videos: related)
    }

    func showThumbnailBackground(image: NSImage) {
        let imageLayer = CALayer()
        imageLayer.frame = bounds
        imageLayer.contents = image
        imageLayer.contentsGravity = .resizeAspectFill
        layer?.insertSublayer(imageLayer, at: 0)
        gradientLayer?.frame = bounds
        layer?.insertSublayer(gradientLayer!, above: imageLayer)
    }

    func populateThumbnails(videos: [PexelsVideo]) {
        thumbnailsContainer.subviews.forEach { $0.removeFromSuperview() }

        var x: CGFloat = 0
        for video in videos.prefix(10) {
            let thumb = MiniThumbnail(
                frame: NSRect(x: x, y: 0, width: 120, height: 75)
            )
            thumb.configure(with: video)
            thumbnailsContainer.addSubview(thumb)
            x += 130
        }

        thumbnailsContainer.frame = NSRect(
            x: 0, y: 0,
            width: x,
            height: 80
        )
    }

    func loadImage(url: URL, completion: @escaping (NSImage) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = NSImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }.resume()
    }

    @objc func setAsWallpaper() {
        guard let video = currentVideo else { return }
        onSetAsWallpaper?(video)
    }

    override func layout() {
        super.layout()
        gradientLayer?.frame = bounds
    }
}

// MARK: - Mini Thumbnail
class MiniThumbnail: NSView {
    var imageView: NSImageView!
    var video: PexelsVideo?

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.masksToBounds = true

        imageView = NSImageView(frame: bounds)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        addSubview(imageView)
    }

    func configure(with video: PexelsVideo) {
        self.video = video
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
}
