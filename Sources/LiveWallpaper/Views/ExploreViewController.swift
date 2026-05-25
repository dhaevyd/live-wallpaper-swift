import Cocoa

class ExploreViewController: NSViewController {
    var wallpaperController: WallpaperController
    var scrollView: NSScrollView!
    var contentView: NSView!
    var searchField: NSSearchField!
    var resultsContainer: NSView!
    var loadingIndicator: NSProgressIndicator!
    var currentCategory: Category?

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
    }

    func setupUI() {
        // Search field
        searchField = NSSearchField(
            frame: NSRect(x: 20, y: 535, width: 860, height: 36)
        )
        searchField.placeholderString = "Search wallpapers..."
        searchField.font = NSFont.systemFont(ofSize: 14)
        searchField.target = self
        searchField.action = #selector(search)
        view.addSubview(searchField)

        // Categories title
        let catTitle = NSTextField(labelWithString: "Categories")
        catTitle.font = NSFont.boldSystemFont(ofSize: 18)
        catTitle.textColor = .white
        catTitle.frame = NSRect(x: 20, y: 490, width: 200, height: 30)
        view.addSubview(catTitle)

        // Categories row
        setupCategoriesRow()

        // Results title
        let resultsTitle = NSTextField(labelWithString: "Results")
        resultsTitle.font = NSFont.boldSystemFont(ofSize: 16)
        resultsTitle.textColor = .white
        resultsTitle.frame = NSRect(x: 20, y: 355, width: 200, height: 25)
        view.addSubview(resultsTitle)

        // Results scroll view
        resultsContainer = NSView(
            frame: NSRect(x: 0, y: 0, width: 3000, height: 330)
        )

        let resultsScroll = NSScrollView(
            frame: NSRect(x: 0, y: 20, width: 900, height: 330)
        )
        resultsScroll.documentView = resultsContainer
        resultsScroll.hasHorizontalScroller = true
        resultsScroll.hasVerticalScroller = false
        resultsScroll.drawsBackground = false
        resultsScroll.horizontalScroller?.alphaValue = 0
        view.addSubview(resultsScroll)

        // Loading indicator
        loadingIndicator = NSProgressIndicator(
            frame: NSRect(x: 430, y: 200, width: 40, height: 40)
        )
        loadingIndicator.style = .spinning
        loadingIndicator.isHidden = true
        view.addSubview(loadingIndicator)

        // Load default category
        loadCategory(Category.all[0])
    }

    func setupCategoriesRow() {
        let scrollView = NSScrollView(
            frame: NSRect(x: 0, y: 375, width: 900, height: 110)
        )
        let container = NSView(
            frame: NSRect(x: 0, y: 0, width: 3000, height: 110)
        )

        var x: CGFloat = 20
        for category in Category.all {
            let card = CategoryCard(
                frame: NSRect(x: x, y: 10, width: 130, height: 80)
            )
            card.configure(with: category)
            card.onSelect = { cat in
                self.loadCategory(cat)
            }
            container.addSubview(card)
            x += 145
        }

        container.frame = NSRect(x: 0, y: 0, width: x, height: 110)
        scrollView.documentView = container
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        view.addSubview(scrollView)
    }

    func loadCategory(_ category: Category) {
        currentCategory = category
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimation(nil)

        PexelsAPI.shared.fetchCategory(category: category) { result in
            self.loadingIndicator.stopAnimation(nil)
            self.loadingIndicator.isHidden = true

            switch result {
            case .success(let videos):
                self.populateResults(videos: videos)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    func populateResults(videos: [PexelsVideo]) {
        resultsContainer.subviews.forEach { $0.removeFromSuperview() }

        var x: CGFloat = 20
        for video in videos {
            let card = VideoCardView(
                frame: NSRect(x: x, y: 10, width: 200, height: 220)
            )
            card.configure(with: video)
            card.onSelect = { selectedVideo in
                self.setAsWallpaper(video: selectedVideo)
            }
            resultsContainer.addSubview(card)
            x += 220
        }

        resultsContainer.frame = NSRect(
            x: 0, y: 0,
            width: x + 20,
            height: 330
        )
    }

    func setAsWallpaper(video: PexelsVideo) {
        VideoDownloader.shared.download(
            video: video,
            progress: { _ in }
        ) { result in
            switch result {
            case .success(let url):
                self.wallpaperController.playVideo(url: url)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    @objc func search() {
        let query = searchField.stringValue
        guard !query.isEmpty else { return }

        loadingIndicator.isHidden = false
        loadingIndicator.startAnimation(nil)

        PexelsAPI.shared.searchVideos(query: query) { result in
            self.loadingIndicator.stopAnimation(nil)
            self.loadingIndicator.isHidden = true

            switch result {
            case .success(let videos):
                self.populateResults(videos: videos)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}

// MARK: - Category Card
class CategoryCard: NSView {
    var onSelect: ((Category) -> Void)?
    var category: Category?
    var emojiLabel: NSTextField!
    var nameLabel: NSTextField!

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
        layer?.backgroundColor = NSColor.white
            .withAlphaComponent(0.08).cgColor

        emojiLabel = NSTextField(labelWithString: "")
        emojiLabel.font = NSFont.systemFont(ofSize: 28)
        emojiLabel.frame = NSRect(x: 0, y: 35, width: 130, height: 35)
        emojiLabel.alignment = .center
        addSubview(emojiLabel)

        nameLabel = NSTextField(labelWithString: "")
        nameLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .white
        nameLabel.frame = NSRect(x: 0, y: 10, width: 130, height: 20)
        nameLabel.alignment = .center
        addSubview(nameLabel)

        let tracking = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(tracking)
    }

    func configure(with category: Category) {
        self.category = category
        emojiLabel.stringValue = category.emoji
        nameLabel.stringValue = category.name
    }

    override func mouseEntered(with event: NSEvent) {
        layer?.backgroundColor = NSColor.white
            .withAlphaComponent(0.15).cgColor
    }

    override func mouseExited(with event: NSEvent) {
        layer?.backgroundColor = NSColor.white
            .withAlphaComponent(0.08).cgColor
    }

    override func mouseDown(with event: NSEvent) {
        guard let category = category else { return }
        onSelect?(category)
    }
}
