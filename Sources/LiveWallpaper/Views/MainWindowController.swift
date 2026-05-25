import Cocoa

class MainWindowController: NSWindowController, NavBarDelegate {
    var wallpaperController: WallpaperController
    var navBar: NavBar!
    var contentArea: NSView!
    var homeVC: HomeViewController!
    var exploreVC: ExploreViewController!
    var libraryVC: LibraryViewController!
    var settingsVC: SettingsViewController!
    var currentVC: NSViewController?

    init(wallpaperController: WallpaperController) {
        self.wallpaperController = wallpaperController

        // Create main window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 640),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )
        window.title = "LiveWall"
        window.center()
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = NSColor(
            red: 0.08,
            green: 0.08,
            blue: 0.08,
            alpha: 1.0
        )
        window.minSize = NSSize(width: 900, height: 640)

        super.init(window: window)
        setupContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupContent() {
        guard let window = self.window else { return }

        // Main container
        let container = NSView(
            frame: NSRect(x: 0, y: 0, width: 900, height: 640)
        )
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor(
            red: 0.08,
            green: 0.08,
            blue: 0.08,
            alpha: 1.0
        ).cgColor
        window.contentView = container

        // Nav bar at top
        navBar = NavBar(
            frame: NSRect(x: 0, y: 588, width: 900, height: 52)
        )
        navBar.delegate = self
        container.addSubview(navBar)

        // Content area below nav
        contentArea = NSView(
            frame: NSRect(x: 0, y: 0, width: 900, height: 588)
        )
        container.addSubview(contentArea)

        // Init view controllers
        homeVC = HomeViewController(
            wallpaperController: wallpaperController
        )
        exploreVC = ExploreViewController(
            wallpaperController: wallpaperController
        )
        libraryVC = LibraryViewController(
            wallpaperController: wallpaperController
        )
        settingsVC = SettingsViewController(
            wallpaperController: wallpaperController
        )

        // Show home by default
        showTab(.home)
    }

    // MARK: - Tab Switching
    func showTab(_ tab: NavTab) {
        // Remove current
        currentVC?.view.removeFromSuperview()

        // Show new
        switch tab {
        case .home:
            contentArea.addSubview(homeVC.view)
            currentVC = homeVC
        case .explore:
            contentArea.addSubview(exploreVC.view)
            currentVC = exploreVC
        case .library:
            // Refresh library each time
            libraryVC.loadVideos()
            contentArea.addSubview(libraryVC.view)
            currentVC = libraryVC
        case .settings:
            contentArea.addSubview(settingsVC.view)
            currentVC = settingsVC
        }
    }

    // MARK: - NavBarDelegate
    func navBar(_ navBar: NavBar, didSelectTab tab: NavTab) {
        showTab(tab)
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
