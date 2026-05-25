import Cocoa
import AVFoundation

class VideoThumbnailItem: NSCollectionViewItem {
    var imageView2: NSImageView!
    var titleLabel: NSTextField!
    var previewPlayer: AVPlayer?
    var previewLayer: AVPlayerLayer?
    var videoURL: URL?

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 180))
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        view.layer?.masksToBounds = true
        setupUI()
    }

    func setupUI() {
        // Thumbnail image
        imageView2 = NSImageView(
            frame: NSRect(x: 0, y: 20, width: 260, height: 155)
        )
        imageView2.imageScaling = .scaleProportionallyUpOrDown
        imageView2.wantsLayer = true
        view.addSubview(imageView2)

        // Title
        titleLabel = NSTextField(labelWithString: "")
        titleLabel.font = NSFont.systemFont(ofSize: 11)
        titleLabel.textColor = .lightGray
        titleLabel.frame = NSRect(x: 5, y: 2, width: 250, height: 16)
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)

        // Hover tracking
        let trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        view.addTrackingArea(trackingArea)
    }

    func configure(with url: URL) {
        self.videoURL = url
        titleLabel.stringValue = url.lastPathComponent
        generateThumbnail(for: url)
        updateSelection()
    }

    func generateThumbnail(for url: URL) {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 60)
        DispatchQueue.global().async {
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                let thumbnail = NSImage(
                    cgImage: cgImage,
                    size: NSSize(width: 260, height: 155)
                )
                DispatchQueue.main.async {
                    self.imageView2.image = thumbnail
                }
            }
        }
    }

    override func mouseEntered(with event: NSEvent) {
        startPreview()
        // Highlight
        view.layer?.borderWidth = 2
        view.layer?.borderColor = NSColor.white.cgColor
    }

    override func mouseExited(with event: NSEvent) {
        stopPreview()
        updateSelection()
    }

    func startPreview() {
        guard let url = videoURL else { return }

        // Hide thumbnail
        imageView2.isHidden = true

        // Setup preview player
        previewPlayer = AVPlayer(url: url)
        previewLayer = AVPlayerLayer(player: previewPlayer!)
        previewLayer!.frame = NSRect(x: 0, y: 20, width: 260, height: 155)
        previewLayer!.videoGravity = .resizeAspectFill
        previewLayer!.cornerRadius = 10
        view.layer?.addSublayer(previewLayer!)
        previewPlayer?.play()

        // Loop preview
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: previewPlayer?.currentItem,
            queue: .main
        ) { _ in
            self.previewPlayer?.seek(to: .zero)
            self.previewPlayer?.play()
        }
    }

    func stopPreview() {
        previewPlayer?.pause()
        previewLayer?.removeFromSuperlayer()
        previewPlayer = nil
        previewLayer = nil
        imageView2.isHidden = false
        view.layer?.borderWidth = 0
    }

    func updateSelection() {
        if isSelected {
            view.layer?.borderWidth = 2
            view.layer?.borderColor = NSColor.controlAccentColor.cgColor
        } else {
            view.layer?.borderWidth = 0
        }
    }
}
