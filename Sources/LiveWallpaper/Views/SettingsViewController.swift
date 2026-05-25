import Cocoa

class SettingsViewController: NSViewController {
    var wallpaperController: WallpaperController

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
    }

    private func setupUI() {
        let stack = NSStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.spacing = 18
        stack.edgeInsets = NSEdgeInsets(top: 28, left: 36, bottom: 28, right: 36)
        view.addSubview(stack)

        let title = WallflowTheme.label("SETTINGS", size: 24, weight: .black, color: .white, tracking: 2)
        stack.addArrangedSubview(title)

        addSection(title: "PLAYBACK", to: stack)
        addToggle(title: "Launch at Login", subtitle: "Start Wallflow when you log in", key: "launchAtLogin", to: stack)
        addToggle(title: "Loop Video", subtitle: "Continuously loop the wallpaper video", key: "loopVideo", defaultValue: true, to: stack)
        addToggle(title: "Mute Audio", subtitle: "Play wallpaper video without sound", key: "muteAudio", defaultValue: true, to: stack)

        addSection(title: "DISPLAY", to: stack)
        addToggle(title: "Same Video on All Screens", subtitle: "Use the same wallpaper on every connected display", key: "sameVideoAllScreens", defaultValue: true, to: stack)

        addSection(title: "ABOUT", to: stack)
        let about = WallflowTheme.label("Wallflow v2.0", size: 12, weight: .regular, color: WallflowTheme.textSecondary)
        stack.addArrangedSubview(about)

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(spacer)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            spacer.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
        ])
    }

    private func addSection(title: String, to stack: NSStackView) {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let label = WallflowTheme.label(title, size: 10, weight: .bold, color: WallflowTheme.accent, tracking: 2.6)
        let separator = NSView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.wantsLayer = true
        separator.layer?.backgroundColor = WallflowTheme.accent.withAlphaComponent(0.28).cgColor
        container.addSubview(label)
        container.addSubview(separator)
        stack.addArrangedSubview(container)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 28),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 14),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func addToggle(title: String, subtitle: String, key: String, defaultValue: Bool = false, to stack: NSStackView) {
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.wantsLayer = true
        row.layer?.backgroundColor = WallflowTheme.surface.cgColor
        row.layer?.cornerRadius = 8
        row.layer?.borderColor = WallflowTheme.border.cgColor
        row.layer?.borderWidth = 1

        let titleLabel = WallflowTheme.label(title, size: 14, weight: .medium, color: .white)
        let subtitleLabel = WallflowTheme.label(subtitle, size: 11, weight: .regular, color: WallflowTheme.textSecondary)
        let toggle = AmberSwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.state = UserDefaults.standard.object(forKey: key) == nil
            ? (defaultValue ? .on : .off)
            : (UserDefaults.standard.bool(forKey: key) ? .on : .off)
        toggle.action = #selector(toggleChanged(_:))
        toggle.target = self
        toggle.identifier = NSUserInterfaceItemIdentifier(key)

        row.addSubview(titleLabel)
        row.addSubview(subtitleLabel)
        row.addSubview(toggle)
        stack.addArrangedSubview(row)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 64),
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 13),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -16),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -16),
            toggle.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
    }

    @objc func toggleChanged(_ sender: NSSwitch) {
        guard let key = sender.identifier?.rawValue else { return }
        UserDefaults.standard.set(sender.state == .on, forKey: key)
        switch key {
        case "muteAudio":
            wallpaperController.setMuted(sender.state == .on)
        case "loopVideo":
            wallpaperController.setLooping(sender.state == .on)
        default:
            break
        }
    }
}

class AmberSwitch: NSSwitch {
    override var state: NSControl.StateValue {
        didSet { updateTint() }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        updateTint()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        updateTint()
    }

    private func updateTint() {
        layer?.backgroundColor = state == .on ? WallflowTheme.accent.withAlphaComponent(0.45).cgColor : NSColor.white.withAlphaComponent(0.12).cgColor
        layer?.cornerRadius = 10
    }
}
