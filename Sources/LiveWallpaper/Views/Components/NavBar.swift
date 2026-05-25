import Cocoa

enum NavTab {
    case home
    case explore
    case library
    case settings
}

protocol NavBarDelegate: AnyObject {
    func navBar(_ navBar: NavBar, didSelectTab tab: NavTab)
}

class NavBar: NSView {
    weak var delegate: NavBarDelegate?
    var currentTab: NavTab = .home

    var homeBtn: NavButton!
    var exploreBtn: NavButton!
    var libraryBtn: NavButton!
    var settingsBtn: NavButton!

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        // Translucent background
        wantsLayer = true
        layer?.backgroundColor = NSColor.black
            .withAlphaComponent(0.4).cgColor

        // App icon + name
        let appIcon = NSImageView(
            frame: NSRect(x: 20, y: 12, width: 28, height: 28)
        )
        appIcon.image = NSImage(
            systemSymbolName: "play.rectangle.fill",
            accessibilityDescription: nil
        )
        appIcon.contentTintColor = .white
        addSubview(appIcon)

        let appName = NSTextField(labelWithString: "LiveWall")
        appName.font = NSFont.boldSystemFont(ofSize: 15)
        appName.textColor = .white
        appName.frame = NSRect(x: 55, y: 15, width: 100, height: 22)
        addSubview(appName)

        // Center nav tabs
        let tabsContainer = NSView(
            frame: NSRect(x: 300, y: 8, width: 320, height: 36)
        )
        tabsContainer.wantsLayer = true
        tabsContainer.layer?.backgroundColor = NSColor.white
            .withAlphaComponent(0.1).cgColor
        tabsContainer.layer?.cornerRadius = 18
        addSubview(tabsContainer)

        // Nav buttons
        homeBtn = NavButton(
            title: "Home",
            frame: NSRect(x: 5, y: 3, width: 90, height: 30)
        )
        homeBtn.action = #selector(homeTapped)
        homeBtn.target = self
        tabsContainer.addSubview(homeBtn)

        exploreBtn = NavButton(
            title: "Explore",
            frame: NSRect(x: 100, y: 3, width: 90, height: 30)
        )
        exploreBtn.action = #selector(exploreTapped)
        exploreBtn.target = self
        tabsContainer.addSubview(exploreBtn)

        libraryBtn = NavButton(
            title: "Library",
            frame: NSRect(x: 200, y: 3, width: 90, height: 30)
        )
        libraryBtn.action = #selector(libraryTapped)
        libraryBtn.target = self
        tabsContainer.addSubview(libraryBtn)

        // Settings button right side
        settingsBtn = NavButton(
            title: "⚙️",
            frame: NSRect(x: 860, y: 8, width: 36, height: 36)
        )
        settingsBtn.action = #selector(settingsTapped)
        settingsBtn.target = self
        addSubview(settingsBtn)

        // Set initial active tab
        setActive(tab: .home)
    }

    func setActive(tab: NavTab) {
        currentTab = tab
        homeBtn.setActive(tab == .home)
        exploreBtn.setActive(tab == .explore)
        libraryBtn.setActive(tab == .library)
        settingsBtn.setActive(tab == .settings)
    }

    @objc func homeTapped() {
        setActive(tab: .home)
        delegate?.navBar(self, didSelectTab: .home)
    }

    @objc func exploreTapped() {
        setActive(tab: .explore)
        delegate?.navBar(self, didSelectTab: .explore)
    }

    @objc func libraryTapped() {
        setActive(tab: .library)
        delegate?.navBar(self, didSelectTab: .library)
    }

    @objc func settingsTapped() {
        setActive(tab: .settings)
        delegate?.navBar(self, didSelectTab: .settings)
    }
}

// MARK: - Nav Button
class NavButton: NSButton {
    init(title: String, frame: NSRect) {
        super.init(frame: frame)
        self.title = title
        self.isBordered = false
        self.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        self.contentTintColor = NSColor.white.withAlphaComponent(0.6)
        self.wantsLayer = true
        self.layer?.cornerRadius = 15
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setActive(_ active: Bool) {
        if active {
            layer?.backgroundColor = NSColor.white
                .withAlphaComponent(0.2).cgColor
            contentTintColor = .white
            font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        } else {
            layer?.backgroundColor = .clear
            contentTintColor = NSColor.white.withAlphaComponent(0.6)
            font = NSFont.systemFont(ofSize: 13, weight: .medium)
        }
    }
}
