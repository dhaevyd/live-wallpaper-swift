import Cocoa
import AVFoundation

class VideoGridViewController: NSViewController {
    var wallpaperController: WallpaperController
    var videoURLs: [URL] = []
    var scrollView: NSScrollView!
    var collectionView: NSCollectionView!
    var folderLabel: NSTextField!
    var currentFolder: URL

    init(wallpaperController: WallpaperController) {
        self.wallpaperController = wallpaperController
        self.currentFolder = VideoGridViewController.defaultFolder()
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
        view = NSView(frame: NSRect(x: 0, y: 0, width: 900, height: 620))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(
            red: 0.08,
            green: 0.08,
            blue: 0.08,
            alpha: 1.0
        ).cgColor
        setupUI()
        loadVideos()
    }

    func setupUI() {
        // Title
        let title = NSTextField(labelWithString: "Live Wallpaper")
        title.font = NSFont.systemFont(ofSize: 28, weight: .semibold)
        title.textColor = .white
        title.frame = NSRect(x: 30, y: 560, width: 400, height: 40)
        view.addSubview(title)

        // Folder label
        folderLabel = NSTextField(
            labelWithString: "📁 \(currentFolder.path)"
        )
        folderLabel.font = NSFont.systemFont(ofSize: 12)
        folderLabel.textColor = NSColor.lightGray
        folderLabel.frame = NSRect(x: 30, y: 535, width: 700, height: 20)
        view.addSubview(folderLabel)

        // Change folder button
        let changeFolderBtn = NSButton(
            title: "Change Folder",
            target: self,
            action: #selector(changeFolder)
        )
        changeFolderBtn.frame = NSRect(x: 780, y: 530, width: 110, height: 28)
        changeFolderBtn.bezelStyle = .rounded
        changeFolderBtn.contentTintColor = .white
        view.addSubview(changeFolderBtn)

        // Divider
        let divider = NSBox()
        divider.boxType = .separator
        divider.frame = NSRect(x: 0, y: 520, width: 900, height: 1)
        view.addSubview(divider)

        // Collection view
        setupCollectionView()

        // Now playing bar
        setupNowPlayingBar()
    }

    func setupCollectionView() {
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 260, height: 180)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = NSEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )

        collectionView = NSCollectionView()
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isSelectable = true
        collectionView.backgroundColors = [.clear]
        collectionView.register(
            VideoThumbnailItem.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("VideoItem")
        )

        scrollView = NSScrollView(
            frame: NSRect(x: 0, y: 50, width: 900, height: 468)
        )
        scrollView.documentView = collectionView
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        view.addSubview(scrollView)
    }

    func setupNowPlayingBar() {
        let bar = NSView(
            frame: NSRect(x: 0, y: 0, width: 900, height: 50)
        )
        bar.wantsLayer = true
        bar.layer?.backgroundColor = NSColor(
            red: 0.12,
            green: 0.12,
            blue: 0.12,
            alpha: 1.0
        ).cgColor

        let nowPlaying = NSTextField(
            labelWithString: "Now Playing: \(wallpaperController.currentVideoName)"
        )
        nowPlaying.font = NSFont.systemFont(ofSize: 13)
        nowPlaying.textColor = .lightGray
        nowPlaying.frame = NSRect(x: 20, y: 15, width: 500, height: 20)
        nowPlaying.tag = 200
        bar.addSubview(nowPlaying)

        // Stop button
        let stopBtn = NSButton(
            title: "Stop",
            target: self,
            action: #selector(stopWallpaper)
        )
        stopBtn.frame = NSRect(x: 800, y: 10, width: 80, height: 30)
        stopBtn.bezelStyle = .rounded
        bar.addSubview(stopBtn)

        view.addSubview(bar)
    }

    func loadVideos() {
        let extensions = ["mp4", "mov", "avi", "mkv", "m4v"]
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: currentFolder,
            includingPropertiesForKeys: nil
        ) else { return }

        videoURLs = files.filter {
            extensions.contains($0.pathExtension.lowercased())
        }
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

    @objc func stopWallpaper() {
        wallpaperController.stopVideo()
        if let bar = view.viewWithTag(200) as? NSTextField {
            bar.stringValue = "Now Playing: None"
        }
    }
}

// MARK: - CollectionView DataSource
extension VideoGridViewController: NSCollectionViewDataSource {
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
            withIdentifier: NSUserInterfaceItemIdentifier("VideoItem"),
            for: indexPath
        ) as! VideoThumbnailItem
        item.configure(with: videoURLs[indexPath.item])
        return item
    }
}

// MARK: - CollectionView Delegate
extension VideoGridViewController: NSCollectionViewDelegate {
    func collectionView(
        _ collectionView: NSCollectionView,
        didSelectItemsAt indexPaths: Set<IndexPath>
    ) {
        guard let indexPath = indexPaths.first else { return }
        let url = videoURLs[indexPath.item]
        wallpaperController.playVideo(url: url)

        if let bar = view.viewWithTag(200) as? NSTextField {
            bar.stringValue = "Now Playing: \(url.lastPathComponent)"
        }
    }
}
