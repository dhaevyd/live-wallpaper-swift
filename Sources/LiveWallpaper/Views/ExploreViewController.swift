import Cocoa

class ExploreViewController: NSViewController {
    var wallpaperController: WallpaperController

    private let searchField = NSSearchField()
    private let chipsStack = NSStackView()
    private let resultsLabel = WallflowTheme.label("RESULTS / 0", size: 11, weight: .bold, color: WallflowTheme.textSecondary, tracking: 2.2)
    private var collectionView: NSCollectionView!
    private var collectionLayout: NSCollectionViewFlowLayout!
    private let loadingIndicator = NSProgressIndicator()
    private var errorView: NSView?
    private var toastView: NSView?
    private var currentCategory: Category?
    private var videos: [PexelsVideo] = []
    private var chipButtons: [CategoryChipButton] = []

    init(wallpaperController: WallpaperController) {
        self.wallpaperController = wallpaperController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = WallflowTheme.background.cgColor
        setupUI()
        loadCategory(Category.all[0])
    }

    private func setupUI() {
        let stack = NSStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.spacing = 18
        stack.edgeInsets = NSEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        view.addSubview(stack)

        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholderString = "Search wallpapers"
        searchField.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        searchField.target = self
        searchField.action = #selector(search)
        searchField.wantsLayer = true
        searchField.layer?.backgroundColor = WallflowTheme.surface.cgColor
        searchField.layer?.borderColor = WallflowTheme.accent.withAlphaComponent(0.35).cgColor
        searchField.layer?.borderWidth = 1
        searchField.layer?.cornerRadius = 8
        stack.addArrangedSubview(searchField)

        let chipsScroll = NSScrollView()
        chipsScroll.translatesAutoresizingMaskIntoConstraints = false
        chipsScroll.drawsBackground = false
        chipsScroll.hasHorizontalScroller = false
        chipsStack.translatesAutoresizingMaskIntoConstraints = false
        chipsStack.orientation = .horizontal
        chipsStack.spacing = 8
        chipsScroll.documentView = chipsStack
        stack.addArrangedSubview(chipsScroll)

        for category in Category.all {
            let chip = CategoryChipButton(category: category)
            chip.target = self
            chip.action = #selector(chipPressed(_:))
            chipButtons.append(chip)
            chipsStack.addArrangedSubview(chip)
        }

        stack.addArrangedSubview(resultsLabel)

        collectionLayout = NSCollectionViewFlowLayout()
        collectionLayout.minimumInteritemSpacing = 14
        collectionLayout.minimumLineSpacing = 14
        collectionLayout.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)

        collectionView = NSCollectionView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.collectionViewLayout = collectionLayout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColors = [.clear]
        collectionView.autoresizingMask = [.width]
        collectionView.register(ExploreVideoItem.self, forItemWithIdentifier: ExploreVideoItem.identifier)

        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = collectionView
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        stack.addArrangedSubview(scrollView)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.style = .spinning
        loadingIndicator.controlSize = .large
        loadingIndicator.isHidden = true
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            chipsScroll.heightAnchor.constraint(equalToConstant: 36),
            chipsStack.leadingAnchor.constraint(equalTo: chipsScroll.contentView.leadingAnchor),
            chipsStack.topAnchor.constraint(equalTo: chipsScroll.contentView.topAnchor),
            chipsStack.bottomAnchor.constraint(equalTo: chipsScroll.contentView.bottomAnchor),
            chipsStack.heightAnchor.constraint(equalTo: chipsScroll.heightAnchor),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 360),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        updateCollectionLayout(for: collectionView?.bounds.width ?? view.bounds.width)
        collectionLayout?.invalidateLayout()
    }

    func loadCategory(_ category: Category) {
        currentCategory = category
        chipButtons.forEach { $0.setActive($0.category.name == category.name) }
        performFetch(retry: { [weak self] in self?.loadCategory(category) }) { completion in
            PexelsAPI.shared.fetchCategory(category: category, completion: completion)
        }
    }

    @objc private func search() {
        let query = searchField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        currentCategory = nil
        chipButtons.forEach { $0.setActive(false) }
        performFetch(retry: { [weak self] in self?.search() }) { completion in
            PexelsAPI.shared.searchVideos(query: query, completion: completion)
        }
    }

    private func performFetch(retry: @escaping () -> Void, fetch: (@escaping (Result<[PexelsVideo], Error>) -> Void) -> Void) {
        errorView?.removeFromSuperview()
        errorView = nil
        guard PexelsAPI.hasAPIKey else {
            videos = []
            resultsLabel.stringValue = "RESULTS / 0"
            collectionView.reloadData()
            showError(title: "PEXELS API KEY REQUIRED", message: "Build Wallflow through GitHub Actions with PEXELS_API_KEY configured, or set it in the local launch environment.", retry: retry)
            return
        }
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimation(nil)
        fetch { [weak self] result in
            guard let self = self else { return }
            self.loadingIndicator.stopAnimation(nil)
            self.loadingIndicator.isHidden = true
            switch result {
            case .success(let videos):
                self.errorView?.removeFromSuperview()
                self.errorView = nil
                self.videos = videos
                self.resultsLabel.stringValue = "RESULTS / \(videos.count)"
                self.updateCollectionLayout(for: self.collectionView.bounds.width)
                self.collectionView.reloadData()
                self.collectionLayout.invalidateLayout()
            case .failure(let error):
                self.showError(title: "FETCH FAILED", message: error.localizedDescription, retry: retry)
            }
        }
    }

    private func updateCollectionLayout(for width: CGFloat) {
        guard width > 0 else { return }
        let insets = collectionLayout.sectionInset.left + collectionLayout.sectionInset.right
        let available = max(180, width - insets)
        let columns = max(1, min(5, Int((available + collectionLayout.minimumInteritemSpacing) / 180)))
        let spacing = CGFloat(columns - 1) * collectionLayout.minimumInteritemSpacing
        let itemWidth = floor((available - spacing) / CGFloat(columns))
        collectionLayout.itemSize = NSSize(width: itemWidth, height: floor(itemWidth * 0.62))
    }

    @objc private func chipPressed(_ sender: CategoryChipButton) {
        loadCategory(sender.category)
    }

    private func setAsWallpaper(video: PexelsVideo) {
        VideoDownloader.shared.download(video: video, progress: { _ in }) { [weak self] result in
            switch result {
            case .success(let url):
                self?.wallpaperController.playVideo(url: url)
                self?.collectionView.reloadData()
            case .failure(let error):
                self?.showToast("DOWNLOAD FAILED: \(error.localizedDescription)")
            }
        }
    }

    private func showError(title: String, message: String, retry: @escaping () -> Void) {
        errorView?.removeFromSuperview()
        let state = ErrorStateView(title: title, message: message, retry: retry)
        errorView = state
        view.addSubview(state)
        NSLayoutConstraint.activate([
            state.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            state.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            state.topAnchor.constraint(equalTo: view.topAnchor),
            state.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func showToast(_ message: String) {
        toastView?.removeFromSuperview()
        let toast = ToastView(message: message)
        toastView = toast
        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -48)
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self, weak toast] in
            toast?.removeFromSuperview()
            if self?.toastView === toast {
                self?.toastView = nil
            }
        }
    }
}

extension ExploreViewController: NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        videos.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: ExploreVideoItem.identifier, for: indexPath) as! ExploreVideoItem
        let video = videos[indexPath.item]
        item.configure(with: video, isCurrent: wallpaperController.currentVideoName == "\(video.id).mp4")
        item.onSelect = { [weak self] selected in
            self?.setAsWallpaper(video: selected)
        }
        return item
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        updateCollectionLayout(for: collectionView.bounds.width)
        return collectionLayout.itemSize
    }
}

class ExploreVideoItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier("ExploreVideoItem")
    var onSelect: ((PexelsVideo) -> Void)?
    private let card = VideoCardView()

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        card.onSelect = { [weak self] video in
            self?.onSelect?(video)
        }
        view.addSubview(card)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            card.topAnchor.constraint(equalTo: view.topAnchor),
            card.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configure(with video: PexelsVideo, isCurrent: Bool) {
        card.configure(with: video, isCurrent: isCurrent)
    }
}

class CategoryChipButton: NSButton {
    let category: Category

    init(category: Category) {
        self.category = category
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        title = category.name.uppercased()
        isBordered = false
        font = NSFont.systemFont(ofSize: 10, weight: .bold)
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.borderWidth = 1
        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: 78),
            heightAnchor.constraint(equalToConstant: 30)
        ])
        setActive(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActive(_ active: Bool) {
        layer?.backgroundColor = active ? WallflowTheme.accent.cgColor : WallflowTheme.surface.cgColor
        layer?.borderColor = active ? WallflowTheme.accent.cgColor : WallflowTheme.border.cgColor
        contentTintColor = active ? .black : WallflowTheme.textSecondary
    }
}
