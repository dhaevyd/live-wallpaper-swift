import Cocoa
import AVFoundation

class LibraryViewController: NSViewController {
    var wallpaperController: WallpaperController
    var videoURLs: [URL] = []
    var collectionView: NSCollectionView!
    var scrollView: NSScrollView!
    var folderLabel: NSTextField!
    var currentFolder: URL
    var emptyLabel: NSTextField!

    init(wallpaperController: WallpaperController) {
        self.wallpaperController = wallpaperController
        self.currentFolder = LibraryViewController.defaultFolder()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func defaultFolder() -> URL {
        let movies = FileManager.default.urls(
            for: .moviesDirectory,
            in: .userDomainMask
        ).first!
        return movies.appendingPathComponent("LiveWallpapers")
    }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 900, height: 580))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(
            red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0
        ).cgColor
        setupUI()
        loadVideos()
    }

    func setupUI() {
        // Title
        let title = NSTextField(labelWithString: "Library")
        title.font = NSFont.boldSystemFont(ofSize: 24)
        title.textColor = .white
        title.frame = NSRect(x: 20, y: 535, width: 200, height: 35)
        view.addSubview(title)

        // Folder label
        folderLabel = NSTextField(
            labelWithString: "📁 \(currentFolder.path)"
        )
        folderLabel.font = NSFont.systemFont(ofSize: 11)
        folderLabel.textColor = .lightGray
        folderLabel.frame = NSRect(x: 20, y: 510, width: 750, height: 20)
        view.addSubview(folderLabel)

        // Change folder button
        let changeFolderBtn = NSButton(
            title: "Change Folder",
            target: self,
            action: #selector(changeFolder)
        )
        changeFolderBtn.frame = NSRect(x: 780, y: 505, width: 110, height: 28)
        changeFolderBtn.bezelStyle = .rounded
        view.addSubview(changeFolderBtn)

        // Divider
        let divider = NSBox()
        divider.boxType = .separator
        divider.frame = NSRect(x: 0, y: 498, width: 900, height: 1)
        view.addSubview(divider)

        // Collection view
        setupCollectionView()

        // Empty state
        emptyLabel = NSTextField(
            labelWithString: "No videos found\nAdd videos to your library folder"
        )
        emptyLabel.font = NSFont.systemFont(ofSize: 14)
        emptyLabel.textColor = .lightGray
        emptyLabel.alignment = .center
        emptyLabel.frame = NSRect(x: 300, y: 280, width: 300, height: 50)
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
    }

    func setupCollectionView() {
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 200, height: 150)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = NSEdgeInsets(
            top: 16, left: 16, bottom: 16, right: 16
        )

        collectionView = NSCollectionView()
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isSelectable = true
        collectionView.backgroundColors = [.clear]
        collectionView.register(
            LibraryVideoItem.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("LibraryItem")
        )

        scrollView = NSScrollView(
            frame: NSRect(x: 0, y: 0, width: 900, height: 495)
        )
        scrollView.documentView = collectionView
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        view.addSubview(scrollView)
    }

    func loadVideos() {
        let extensions = ["mp4", "mov", "avi", "mkv", "m4v"]
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: currentFolder,
            includingPropertiesForKeys: nil
        ) else {
            emptyLabel.isHidden = false
            return
        }

        videoURLs = files.filter {
            extensions.contains($0.pathExtension.lowercased())
        }

        emptyLabel.isHidden = !videoURLs.isEmpty
        collectionView.reloadData()
    }

    @objc func changeFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.currentFolder = url
                self.folderLabel.stringValue = "📁 \(url.path)"
                self.loadVideos()
            }
        }
    }
}

// MARK: - CollectionView DataSource
extension LibraryViewController: NSCollectionViewDataSource {
    func collectionView(
        _ collectionView: NSCollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return videoURLs.count
    }

    func collectionView(
        _ collectionView: NSCollectionView,
        itemForRepresentedObjectAt indexPath: IndexPath
    ) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier("LibraryItem"),
            for: indexPath
        ) as! LibraryVideoItem
        item.configure(with: videoURLs[indexPath.item])
        item.onSelect = { url in
            self.wallpaperController.playVideo(url: url)
        }
        return item
    }
}

// MARK: - CollectionView Delegate
extension LibraryViewController: NSCollectionViewDelegate {
    func collectionView(
        _ collectionView: NSCollectionView,
        didSelectItemsAt indexPaths: Set<IndexPath>
    ) {}
}

// MARK: - Library Video Item
class LibraryVideoItem: NSCollectionViewItem {
    var videoURL: URL?
    var onSelect: ((URL) -> Void)?
    var thumbView: NSImageView!
    var titleLabel: NSTextField!
    var previewPlayer: AVPlayer?
    var previewLayer: AVPlayerLayer?

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 150))
        view.wantsLayer = true
        view.layer?.cornerRadius = 10
        view.layer?.masksToBounds = true
        setupUI()
    }

    func setupUI() {
        thumbView = NSImageView(
            frame: NSRect(x: 0, y: 20, width: 200, height: 125)
        )
        thumbView.imageScaling = .scaleProportionallyUpOrDown
        view.addSubview(thumbView)

        titleLabel = NSTextField(labelWithString: "")
        titleLabel.font = NSFont.systemFont(ofSize: 11)
        titleLabel.textColor = .lightGray
        titleLabel.frame = NSRect(x: 5, y: 2, width: 190, height: 16)
        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)

        let tracking = NSTrackingArea(
            rect: view.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        view.addTrackingArea(tracking)
    }

    func configure(with url: URL) {
        self.videoURL = url
        titleLabel.stringValue = url.lastPathComponent
        generateThumbnail(url: url)
    }

    func generateThumbnail(url: URL) {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60)

        DispatchQueue.global().async {
            if let cgImage = try? generator.copyCGImage(
                at: time, actualTime: nil
            ) {
                let image = NSImage(
                    cgImage: cgImage,
                    size: NSSize(width: 200, height: 125)
                )
                DispatchQueue.main.async {
                    self.thumbView.image = image
                }
            }
        }
    }

    override func mouseEntered(with event: NSEvent) {
        guard let url = videoURL else { return }
        thumbView.isHidden = true
        previewPlayer = AVPlayer(url: url)
        previewLayer = AVPlayerLayer(player: previewPlayer!)
        previewLayer!.frame = NSRect(x: 0, y: 20, width: 200, height: 125)
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer?.addSublayer(previewLayer!)
        previewPlayer?.play()
        view.layer?.borderWidth = 2
        view.layer?.borderColor = NSColor.white.cgColor
    }

    override func mouseExited(with event: NSEvent) {
        previewPlayer?.pause()
        previewLayer?.removeFromSuperlayer()
        previewPlayer = nil
        previewLayer = nil
        thumbView.isHidden = false
        view.layer?.borderWidth = 0
    }

    override func mouseDown(with event: NSEvent) {
        guard let url = videoURL else { return }
        onSelect?(url)
    }
}
