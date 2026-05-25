import Cocoa
import AVFoundation

class LibraryViewController: NSViewController {
    var wallpaperController: WallpaperController
    var videoURLs: [URL] = []
    var currentFolder: URL

    private var collectionView: NSCollectionView!
    private let folderLabel = WallflowTheme.label("", size: 11, weight: .regular, color: WallflowTheme.textSecondary)
    private let countLabel = WallflowTheme.label("0 VIDEOS", size: 11, weight: .bold, color: WallflowTheme.textSecondary, tracking: 2)
    private var emptyView: NSView?

    init(wallpaperController: WallpaperController) {
        self.wallpaperController = wallpaperController
        self.currentFolder = LibraryViewController.defaultFolder()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func defaultFolder() -> URL {
        let movies = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first!
        return movies.appendingPathComponent("LiveWallpapers")
    }

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = WallflowTheme.background.cgColor
        setupUI()
        loadVideos()
    }

    private func setupUI() {
        let header = NSView()
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let title = WallflowTheme.label("LIBRARY", size: 24, weight: .black, color: .white, tracking: 2)
        header.addSubview(title)

        let changeFolderBtn = NSButton(title: "CHANGE FOLDER", target: self, action: #selector(changeFolder))
        changeFolderBtn.translatesAutoresizingMaskIntoConstraints = false
        changeFolderBtn.isBordered = false
        changeFolderBtn.font = NSFont.systemFont(ofSize: 10, weight: .heavy)
        changeFolderBtn.contentTintColor = .black
        changeFolderBtn.wantsLayer = true
        changeFolderBtn.layer?.backgroundColor = WallflowTheme.accent.cgColor
        changeFolderBtn.layer?.cornerRadius = 3
        header.addSubview(changeFolderBtn)

        let folderIcon = WallflowTheme.icon("folder.fill", size: 13, color: WallflowTheme.accent)
        view.addSubview(folderIcon)
        view.addSubview(folderLabel)
        view.addSubview(countLabel)

        let separator = NSView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.wantsLayer = true
        separator.layer?.backgroundColor = WallflowTheme.accent.withAlphaComponent(0.35).cgColor
        view.addSubview(separator)

        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 220, height: 164)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 18
        layout.sectionInset = NSEdgeInsets(top: 18, left: 24, bottom: 24, right: 24)

        collectionView = NSCollectionView()
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColors = [.clear]
        collectionView.register(LibraryVideoItem.self, forItemWithIdentifier: LibraryVideoItem.identifier)

        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = collectionView
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            header.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            header.heightAnchor.constraint(equalToConstant: 34),
            title.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            title.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            changeFolderBtn.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            changeFolderBtn.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            changeFolderBtn.widthAnchor.constraint(equalToConstant: 122),
            changeFolderBtn.heightAnchor.constraint(equalToConstant: 30),

            folderIcon.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            folderIcon.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 14),
            folderIcon.widthAnchor.constraint(equalToConstant: 16),
            folderIcon.heightAnchor.constraint(equalToConstant: 16),
            folderLabel.leadingAnchor.constraint(equalTo: folderIcon.trailingAnchor, constant: 8),
            folderLabel.centerYAnchor.constraint(equalTo: folderIcon.centerYAnchor),
            folderLabel.trailingAnchor.constraint(lessThanOrEqualTo: countLabel.leadingAnchor, constant: -12),
            countLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            countLabel.centerYAnchor.constraint(equalTo: folderIcon.centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            separator.topAnchor.constraint(equalTo: folderIcon.bottomAnchor, constant: 14),
            separator.heightAnchor.constraint(equalToConstant: 1),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: separator.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func loadVideos() {
        let extensions = ["mp4", "mov", "avi", "mkv", "m4v"]
        let files = (try? FileManager.default.contentsOfDirectory(at: currentFolder, includingPropertiesForKeys: nil)) ?? []
        videoURLs = files.filter { extensions.contains($0.pathExtension.lowercased()) }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        folderLabel.stringValue = currentFolder.path
        countLabel.stringValue = "\(videoURLs.count) VIDEOS"
        collectionView?.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        emptyView?.removeFromSuperview()
        guard videoURLs.isEmpty else { return }
        let state = EmptyLibraryView()
        emptyView = state
        view.addSubview(state)
        NSLayoutConstraint.activate([
            state.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            state.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            state.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -48)
        ])
    }

    @objc func changeFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.currentFolder = url
                self.loadVideos()
            }
        }
    }
}

extension LibraryViewController: NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        videoURLs.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: LibraryVideoItem.identifier, for: indexPath) as! LibraryVideoItem
        let url = videoURLs[indexPath.item]
        item.configure(with: url, isCurrent: wallpaperController.currentVideoURL == url)
        item.onSelect = { [weak self] selected in
            self?.wallpaperController.playVideo(url: selected)
            self?.collectionView.reloadData()
        }
        return item
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let width = max(190, floor((collectionView.bounds.width - 80) / 3))
        return NSSize(width: width, height: 164)
    }
}

class LibraryVideoItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("LibraryVideoItem")
    var onSelect: ((URL) -> Void)?

    private var videoURL: URL?
    private let imageView = NSImageView()
    private let titleLabel = WallflowTheme.label("", size: 11, weight: .semibold, color: .white)
    private let checkBadge = NSView()
    private var previewPlayer: AVPlayer?
    private var previewLayer: AVPlayerLayer?
    private var previewWorkItem: DispatchWorkItem?
    private var trackingAreaRef: NSTrackingArea?

    override func loadView() {
        view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.masksToBounds = true
        view.layer?.backgroundColor = WallflowTheme.surface.cgColor
        view.layer?.borderWidth = 1
        view.layer?.borderColor = WallflowTheme.border.cgColor
        setupUI()
    }

    private func setupUI() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.wantsLayer = true
        imageView.imageScaling = .scaleAxesIndependently
        view.addSubview(imageView)

        titleLabel.lineBreakMode = .byTruncatingTail
        view.addSubview(titleLabel)

        checkBadge.translatesAutoresizingMaskIntoConstraints = false
        checkBadge.wantsLayer = true
        checkBadge.layer?.backgroundColor = WallflowTheme.accent.cgColor
        checkBadge.layer?.cornerRadius = 8
        checkBadge.isHidden = true
        view.addSubview(checkBadge)

        let check = WallflowTheme.icon("checkmark", size: 9, color: .black)
        checkBadge.addSubview(check)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            checkBadge.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            checkBadge.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            checkBadge.widthAnchor.constraint(equalToConstant: 16),
            checkBadge.heightAnchor.constraint(equalToConstant: 16),
            check.centerXAnchor.constraint(equalTo: checkBadge.centerXAnchor),
            check.centerYAnchor.constraint(equalTo: checkBadge.centerYAnchor),
            check.widthAnchor.constraint(equalToConstant: 10),
            check.heightAnchor.constraint(equalToConstant: 10)
        ])
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingAreaRef = trackingAreaRef {
            view.removeTrackingArea(trackingAreaRef)
        }
        let area = NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        trackingAreaRef = area
        view.addTrackingArea(area)
    }

    func configure(with url: URL, isCurrent: Bool) {
        videoURL = url
        titleLabel.stringValue = url.lastPathComponent
        checkBadge.isHidden = !isCurrent
        view.layer?.borderColor = isCurrent ? WallflowTheme.accent.withAlphaComponent(0.55).cgColor : WallflowTheme.border.cgColor
        generateThumbnail(url: url)
    }

    private func generateThumbnail(url: URL) {
        imageView.image = nil
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        DispatchQueue.global(qos: .userInitiated).async {
            let cgImage = try? generator.copyCGImage(at: time, actualTime: nil)
            DispatchQueue.main.async {
                guard self.videoURL == url, let cgImage = cgImage else { return }
                self.imageView.image = NSImage(cgImage: cgImage, size: .zero)
            }
        }
    }

    override func mouseEntered(with event: NSEvent) {
        previewWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in self?.startPreview() }
        previewWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: item)
    }

    override func mouseExited(with event: NSEvent) {
        previewWorkItem?.cancel()
        stopPreview()
    }

    override func mouseDown(with event: NSEvent) {
        guard let videoURL = videoURL else { return }
        onSelect?(videoURL)
    }

    private func startPreview() {
        guard previewPlayer == nil, let url = videoURL else { return }
        imageView.isHidden = true
        let player = AVPlayer(url: url)
        player.isMuted = true
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        previewPlayer = player
        previewLayer = layer
        view.layer?.insertSublayer(layer, at: 1)
        view.needsLayout = true
        player.play()
    }

    private func stopPreview() {
        previewPlayer?.pause()
        previewLayer?.removeFromSuperlayer()
        previewPlayer = nil
        previewLayer = nil
        imageView.isHidden = false
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer?.frame = imageView.frame
        CATransaction.commit()
    }
}

class EmptyLibraryView: NSView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let icon = WallflowTheme.icon("film.stack.fill", size: 34, color: WallflowTheme.accent)
        let title = WallflowTheme.label("NO VIDEOS FOUND", size: 16, weight: .black, color: .white, tracking: 2)
        let subtitle = WallflowTheme.label("Add videos to the selected Wallflow library folder.", size: 12, weight: .regular, color: WallflowTheme.textSecondary)
        let stack = NSStackView(views: [icon, title, subtitle])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 10
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
