import Cocoa

class HomeViewController: NSViewController {
    var wallpaperController: WallpaperController
    var heroView: HeroView!
    var sectionTitle: NSTextField!
    var scrollView: NSScrollView!
    var cardsContainer: NSView!
    var loadingIndicator: NSProgressIndicator!
    var videos: [PexelsVideo] = []

    init(wallpaperController: WallpaperController) {
        self.wallpaperController = wallpaperController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 900, height: 580))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(
            red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0
        ).cgColor
        setupUI()
        fetchVideos()
    }

    func setupUI() {
        // Hero view top half
        heroView = HeroView(
            frame: NSRect(x: 0, y: 300, width: 900, height: 280)
        )
        heroView.onSetAsWallpaper = { video in
            self.setAsWallpaper(video: video)
        }
        view.addSubview(heroView)

        // Section title
        sectionTitle = NSTextField(
            labelWithString: "✦  Curated Picks"
        )
        sectionTitle.font = NSFont.boldSystemFont(ofSize: 16)
        sectionTitle.textColor = .white
        sectionTitle.frame = NSRect(x: 20, y: 265, width: 300, height: 25)
        view.addSubview(sectionTitle)

        // Cards scroll view
        cardsContainer = NSView(
            frame: NSRect(x: 0, y: 0, width: 3000, height: 240)
        )

        scrollView = NSScrollView(
            frame: NSRect(x: 0, y: 20, width: 900, height: 240)
        )
        scrollView.documentView = cardsContainer
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
        scrollView.drawsBackground = false
        scrollView.horizontalScroller?.alphaValue = 0
        view.addSubview(scrollView)

        // Loading indicator
        loadingIndicator = NSProgressIndicator(
            frame: NSRect(x: 430, y: 400, width: 40, height: 40)
        )
        loadingIndicator.style = .spinning
        loadingIndicator.isHidden = true
        view.addSubview(loadingIndicator)
    }

    func fetchVideos() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimation(nil)

        PexelsAPI.shared.fetchFeatured { result in
            self.loadingIndicator.stopAnimation(nil)
            self.loadingIndicator.isHidden = true

            switch result {
            case .success(let videos):
                self.videos = videos
                self.updateUI(with: videos)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    func updateUI(with videos: [PexelsVideo]) {
        guard !videos.isEmpty else { return }

        // Set hero to first video
        heroView.configure(
            with: videos[0],
            related: Array(videos.prefix(8))
        )

        // Populate cards
        cardsContainer.subviews.forEach { $0.removeFromSuperview() }

        var x: CGFloat = 20
        for video in videos {
            let card = VideoCardView(
                frame: NSRect(x: x, y: 10, width: 200, height: 220)
            )
            card.configure(with: video)
            card.onSelect = { selectedVideo in
                self.setAsWallpaper(video: selectedVideo)
            }
            cardsContainer.addSubview(card)
            x += 220
        }

        cardsContainer.frame = NSRect(
            x: 0, y: 0,
            width: x + 20,
            height: 240
        )
    }

    func setAsWallpaper(video: PexelsVideo) {
        // Show download progress
        let alert = NSAlert()
        alert.messageText = "Downloading..."
        alert.informativeText = "Please wait while we download your wallpaper"
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: view.window!) { _ in
            VideoDownloader.shared.cancelDownload(video: video)
        }

        VideoDownloader.shared.download(
            video: video,
            progress: { progress in
                print("Progress: \(progress)")
            }
        ) { result in
            // Dismiss alert
            self.view.window?.endSheet(
                self.view.window!.sheets.first ?? NSWindow()
            )

            switch result {
