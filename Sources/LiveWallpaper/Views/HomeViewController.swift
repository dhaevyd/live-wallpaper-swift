import Cocoa

class HomeViewController: NSViewController {
    var wallpaperController: WallpaperController
    var heroView: HeroView!

    private let contentStack = NSStackView()
    private let cardsStack = NSStackView()
    private let scrollView = NSScrollView()
    private let loadingIndicator = NSProgressIndicator()
    private var errorView: NSView?
    private var toastView: NSView?
    private var videos: [PexelsVideo] = []

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
        fetchVideos()
    }

    private func setupUI() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.orientation = .vertical
        contentStack.spacing = 18
        contentStack.edgeInsets = NSEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        view.addSubview(contentStack)

        heroView = HeroView()
        heroView.onSetAsWallpaper = { [weak self] video in
            self?.setAsWallpaper(video: video)
        }
        contentStack.addArrangedSubview(heroView)

        let header = WallflowTheme.label("CURATED PICKS", size: 11, weight: .bold, color: WallflowTheme.textSecondary, tracking: 2.4)
        contentStack.addArrangedSubview(header)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.drawsBackground = false
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
        scrollView.scrollerStyle = .overlay
        cardsStack.translatesAutoresizingMaskIntoConstraints = false
        cardsStack.orientation = .horizontal
        cardsStack.spacing = 14
        cardsStack.edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 24)
        scrollView.documentView = cardsStack
        contentStack.addArrangedSubview(scrollView)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.style = .spinning
        loadingIndicator.controlSize = .large
        loadingIndicator.isHidden = true
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: view.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            heroView.heightAnchor.constraint(greaterThanOrEqualToConstant: 310),
            scrollView.heightAnchor.constraint(equalToConstant: 128),
            cardsStack.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            cardsStack.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
            cardsStack.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor),
            cardsStack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func fetchVideos() {
        if ProcessInfo.processInfo.environment["PEXELS_API_KEY", default: ""].isEmpty {
            showError(title: "PEXELS API KEY REQUIRED", message: "Set PEXELS_API_KEY in the launch environment, then reopen LiveWall.", retry: nil)
            return
        }

        errorView?.removeFromSuperview()
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimation(nil)

        PexelsAPI.shared.fetchFeatured { [weak self] result in
            guard let self = self else { return }
            self.loadingIndicator.stopAnimation(nil)
            self.loadingIndicator.isHidden = true

            switch result {
            case .success(let videos):
                self.videos = videos
                self.updateUI(with: videos)
            case .failure(let error):
                self.showError(title: "FETCH FAILED", message: error.localizedDescription) { [weak self] in
                    self?.fetchVideos()
                }
            }
        }
    }

    private func updateUI(with videos: [PexelsVideo]) {
        guard !videos.isEmpty else {
            showError(title: "NO RESULTS", message: "Pexels returned no featured wallpapers.") { [weak self] in
                self?.fetchVideos()
            }
            return
        }

        errorView?.removeFromSuperview()
        heroView.configure(with: videos[0], related: Array(videos.prefix(8)))
        cardsStack.arrangedSubviews.forEach { child in
            cardsStack.removeArrangedSubview(child)
            child.removeFromSuperview()
        }

        for video in videos {
            let card = VideoCardView()
            card.configure(with: video, isCurrent: wallpaperController.currentVideoName == "\(video.id).mp4")
            card.onSelect = { [weak self] selectedVideo in
                self?.setAsWallpaper(video: selectedVideo)
            }
            cardsStack.addArrangedSubview(card)
            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 160),
                card.heightAnchor.constraint(equalToConstant: 110)
            ])
        }
    }

    private func setAsWallpaper(video: PexelsVideo) {
        VideoDownloader.shared.download(video: video, progress: { _ in }) { [weak self] result in
            switch result {
            case .success(let url):
                self?.wallpaperController.playVideo(url: url)
                self?.updateUI(with: self?.videos ?? [])
            case .failure(let error):
                self?.showToast("DOWNLOAD FAILED: \(error.localizedDescription)")
            }
        }
    }

    private func showError(title: String, message: String, retry: (() -> Void)? = nil) {
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

class ErrorStateView: NSView {
    private let retry: (() -> Void)?

    init(title: String, message: String, retry: (() -> Void)?) {
        self.retry = retry
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.backgroundColor = WallflowTheme.background.cgColor

        let icon = WallflowTheme.icon("exclamationmark.triangle.fill", size: 34, color: WallflowTheme.accent)
        let titleLabel = WallflowTheme.label(title, size: 18, weight: .black, color: .white, tracking: 2)
        let messageLabel = WallflowTheme.label(message, size: 13, weight: .regular, color: WallflowTheme.textSecondary)
        messageLabel.alignment = .center
        messageLabel.maximumNumberOfLines = 3

        let stack = NSStackView(views: [icon, titleLabel, messageLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 12
        addSubview(stack)

        var constraints = [
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 460)
        ]

        if retry != nil {
            let retryButton = NSButton(title: "RETRY", target: self, action: #selector(retryPressed))
            retryButton.translatesAutoresizingMaskIntoConstraints = false
            retryButton.isBordered = false
            retryButton.font = NSFont.systemFont(ofSize: 10, weight: .heavy)
            retryButton.contentTintColor = .black
            retryButton.wantsLayer = true
            retryButton.layer?.backgroundColor = WallflowTheme.accent.cgColor
            retryButton.layer?.cornerRadius = 3
            stack.addArrangedSubview(retryButton)
            constraints.append(retryButton.widthAnchor.constraint(equalToConstant: 92))
            constraints.append(retryButton.heightAnchor.constraint(equalToConstant: 30))
        }
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func retryPressed() {
        retry?()
    }
}

class ToastView: NSView {
    init(message: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.86).cgColor
        layer?.cornerRadius = 8
        layer?.borderWidth = 1
        layer?.borderColor = WallflowTheme.accent.withAlphaComponent(0.35).cgColor

        let label = WallflowTheme.label(message, size: 12, weight: .semibold, color: .white)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
