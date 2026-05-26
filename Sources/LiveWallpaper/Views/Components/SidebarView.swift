import Cocoa

enum NavTab {
    case home
    case explore
    case library
    case settings
}

protocol SidebarViewDelegate: AnyObject {
    func sidebar(_ sidebar: SidebarView, didSelectTab tab: NavTab)
}

enum WallflowTheme {
    static let background = NSColor(calibratedRed: 0.047, green: 0.047, blue: 0.047, alpha: 1.0)
    static let surface = NSColor.white.withAlphaComponent(0.06)
    static let surfaceHover = NSColor.white.withAlphaComponent(0.08)
    static let accent = NSColor(calibratedRed: 0.961, green: 0.620, blue: 0.043, alpha: 1.0)
    static let accentHover = NSColor(calibratedRed: 0.984, green: 0.749, blue: 0.141, alpha: 1.0)
    static let danger = NSColor(calibratedRed: 0.937, green: 0.267, blue: 0.267, alpha: 1.0)
    static let success = NSColor(calibratedRed: 0.204, green: 0.773, blue: 0.349, alpha: 1.0)
    static let textPrimary = NSColor.white
    static let textSecondary = NSColor.white.withAlphaComponent(0.35)
    static let border = NSColor.white.withAlphaComponent(0.08)

    static func label(_ text: String, size: CGFloat, weight: NSFont.Weight, color: NSColor, tracking: CGFloat = 0) -> NSTextField {
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = color
        label.font = NSFont.systemFont(ofSize: size, weight: weight)
        if tracking == 0 {
            label.stringValue = text
        } else {
            label.attributedStringValue = NSAttributedString(
                string: text,
                attributes: [
                    .kern: tracking,
                    .font: label.font as Any,
                    .foregroundColor: color
                ]
            )
        }
        return label
    }

    static func icon(_ symbol: String, size: CGFloat = 18, color: NSColor = textSecondary) -> NSImageView {
        let imageView = NSImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        imageView.contentTintColor = color
        imageView.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: size, weight: .semibold)
        return imageView
    }
}

class SidebarView: NSView {
    weak var delegate: SidebarViewDelegate?
    private var currentTab: NavTab = .home
    private var buttons: [NavTab: SidebarButton] = [:]

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.24).cgColor
        layer?.borderColor = WallflowTheme.border.cgColor
        layer?.borderWidth = 1

        let logo = NSImageView()
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.image = WallflowAssets.appIcon
        logo.imageScaling = .scaleProportionallyUpOrDown
        logo.wantsLayer = true
        logo.layer?.cornerRadius = 8
        logo.layer?.masksToBounds = true
        addSubview(logo)

        let stack = NSStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.spacing = 10
        stack.alignment = .centerX
        addSubview(stack)

        addButton(.home, symbol: "house.fill", title: "HOME", to: stack)
        addButton(.explore, symbol: "sparkle.magnifyingglass", title: "EXPLORE", to: stack)
        addButton(.library, symbol: "rectangle.stack.fill", title: "LIBRARY", to: stack)

        let settingsButton = SidebarButton(tab: .settings, symbol: "gearshape.fill", title: "SETTINGS")
        settingsButton.target = self
        settingsButton.action = #selector(tabPressed(_:))
        buttons[.settings] = settingsButton
        addSubview(settingsButton)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 64),
            logo.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            logo.centerXAnchor.constraint(equalTo: centerXAnchor),
            logo.widthAnchor.constraint(equalToConstant: 32),
            logo.heightAnchor.constraint(equalToConstant: 32),

            stack.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 34),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),

            settingsButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            settingsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 52),
            settingsButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        setActive(tab: .home)
    }

    private func addButton(_ tab: NavTab, symbol: String, title: String, to stack: NSStackView) {
        let button = SidebarButton(tab: tab, symbol: symbol, title: title)
        button.target = self
        button.action = #selector(tabPressed(_:))
        buttons[tab] = button
        stack.addArrangedSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 52),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setActive(tab: NavTab) {
        currentTab = tab
        buttons.forEach { key, button in
            button.setActive(key == tab)
        }
    }

    @objc private func tabPressed(_ sender: SidebarButton) {
        setActive(tab: sender.tab)
        delegate?.sidebar(self, didSelectTab: sender.tab)
    }
}

private class GradientLogoView: NSView {
    private let gradient = CAGradientLayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        gradient.colors = [
            WallflowTheme.accentHover.cgColor,
            WallflowTheme.accent.cgColor,
            WallflowTheme.danger.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.cornerRadius = 8
        layer?.addSublayer(gradient)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        gradient.frame = bounds
    }
}

class SidebarButton: NSButton {
    let tab: NavTab
    private let iconView: NSImageView
    private let titleText: String
    private let inactiveColor = WallflowTheme.textSecondary
    private var trackingAreaRef: NSTrackingArea?
    private var active = false

    init(tab: NavTab, symbol: String, title: String) {
        self.tab = tab
        self.titleText = title
        self.iconView = WallflowTheme.icon(symbol, size: 17)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isBordered = false
        self.title = ""
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.borderWidth = 1

        let label = WallflowTheme.label(title, size: 7, weight: .semibold, color: inactiveColor, tracking: 1.2)
        addSubview(iconView)
        addSubview(label)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4),
            label.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingAreaRef = trackingAreaRef {
            removeTrackingArea(trackingAreaRef)
        }
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self, userInfo: nil)
        trackingAreaRef = area
        addTrackingArea(area)
    }

    func setActive(_ active: Bool) {
        self.active = active
        layer?.backgroundColor = active ? WallflowTheme.accent.withAlphaComponent(0.15).cgColor : NSColor.clear.cgColor
        layer?.borderColor = active ? WallflowTheme.accent.withAlphaComponent(0.35).cgColor : NSColor.clear.cgColor
        iconView.contentTintColor = active ? WallflowTheme.accent : inactiveColor
        subviews.compactMap { $0 as? NSTextField }.forEach { label in
            label.attributedStringValue = NSAttributedString(
                string: titleText,
                attributes: [
                    .kern: 1.2,
                    .font: NSFont.systemFont(ofSize: 7, weight: .semibold),
                    .foregroundColor: active ? WallflowTheme.accent : inactiveColor
                ]
            )
        }
    }

    override func mouseEntered(with event: NSEvent) {
        if !active {
            layer?.backgroundColor = NSColor.white.withAlphaComponent(0.06).cgColor
        }
    }

    override func mouseExited(with event: NSEvent) {
        if !active {
            layer?.backgroundColor = NSColor.clear.cgColor
        }
    }
}
