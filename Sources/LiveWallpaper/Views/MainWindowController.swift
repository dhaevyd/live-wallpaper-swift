import Cocoa

class MainWindowController: NSWindowController, SidebarViewDelegate, NSWindowDelegate {
    var wallpaperController: WallpaperController
    var sidebar: SidebarView!
    var contentArea: NSView!
    var homeVC: HomeViewController!
    var exploreVC: ExploreViewController!
    var libraryVC: LibraryViewController!
    var settingsVC: SettingsViewController!
    var currentVC: NSViewController?
    private let hostController = NSViewController()
    private let contentController = NSViewController()

    init(wallpaperController: WallpaperController) {
        self.wallpaperController = wallpaperController

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 640),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Wallflow"
        window.center()
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = WallflowTheme.background
        window.minSize = NSSize(width: 720, height: 520)

        super.init(window: window)
        window.delegate = self
        setupContent()
        observeVisibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupContent() {
        guard let window = self.window else { return }

        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = WallflowTheme.background.cgColor
        hostController.view = container
        window.contentViewController = hostController

        sidebar = SidebarView()
        sidebar.delegate = self
        container.addSubview(sidebar)

        contentArea = NSView()
        contentArea.translatesAutoresizingMaskIntoConstraints = false
        contentArea.wantsLayer = true
        contentArea.layer?.backgroundColor = WallflowTheme.background.cgColor
        contentController.view = contentArea
        hostController.addChild(contentController)
        container.addSubview(contentArea)

        NSLayoutConstraint.activate([
            sidebar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            sidebar.topAnchor.constraint(equalTo: container.topAnchor),
            sidebar.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            contentArea.leadingAnchor.constraint(equalTo: sidebar.trailingAnchor),
            contentArea.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contentArea.topAnchor.constraint(equalTo: container.topAnchor),
            contentArea.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        homeVC = HomeViewController(wallpaperController: wallpaperController)
        exploreVC = ExploreViewController(wallpaperController: wallpaperController)
        libraryVC = LibraryViewController(wallpaperController: wallpaperController)
        settingsVC = SettingsViewController(wallpaperController: wallpaperController)

        showTab(.home)
    }

    func showTab(_ tab: NavTab) {
        sidebar?.setActive(tab: tab)
        let nextVC: NSViewController
        switch tab {
        case .home:
            nextVC = homeVC
        case .explore:
            nextVC = exploreVC
        case .library:
            libraryVC.loadVideos()
            nextVC = libraryVC
        case .settings:
            nextVC = settingsVC
        }

        guard nextVC !== currentVC else { return }

        if let currentVC = currentVC {
            contentController.addChild(nextVC)
            nextVC.view.translatesAutoresizingMaskIntoConstraints = false
            contentController.transition(from: currentVC, to: nextVC, options: [.crossfade]) {
                self.pinContentView(nextVC.view)
                currentVC.removeFromParent()
                self.currentVC = nextVC
            }
        } else {
            contentController.addChild(nextVC)
            nextVC.view.translatesAutoresizingMaskIntoConstraints = false
            contentArea.addSubview(nextVC.view)
            pinContentView(nextVC.view)
            currentVC = nextVC
        }
    }

    private func pinContentView(_ childView: NSView) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        if childView.superview !== contentArea {
            contentArea.addSubview(childView)
        }
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: contentArea.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: contentArea.trailingAnchor),
            childView.topAnchor.constraint(equalTo: contentArea.topAnchor),
            childView.bottomAnchor.constraint(equalTo: contentArea.bottomAnchor)
        ])
    }

    private func observeVisibility() {
        NotificationCenter.default.addObserver(self, selector: #selector(suspendHero), name: NSWindow.didMiniaturizeNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeHero), name: NSWindow.didDeminiaturizeNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(suspendHero), name: NSApplication.didHideNotification, object: NSApp)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeHero), name: NSApplication.didUnhideNotification, object: NSApp)
    }

    @objc private func suspendHero() {
        homeVC?.heroView?.suspendPlayback()
    }

    @objc private func resumeHero() {
        homeVC?.heroView?.resumePlayback()
    }

    func sidebar(_ sidebar: SidebarView, didSelectTab tab: NavTab) {
        showTab(tab)
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        suspendHero()
    }
}
