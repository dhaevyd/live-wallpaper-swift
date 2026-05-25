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
        view = NSView(frame: NSRect(x: 0, y: 0, width: 900, height: 580))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(
            red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0
        ).cgColor
        setupUI()
    }

    func setupUI() {
        // Title
        let title = NSTextField(labelWithString: "Settings")
        title.font = NSFont.boldSystemFont(ofSize: 24)
        title.textColor = .white
        title.frame = NSRect(x: 40, y: 510, width: 200, height: 35)
        view.addSubview(title)

        // Divider
        let divider = NSBox()
        divider.boxType = .separator
        divider.frame = NSRect(x: 0, y: 498, width: 900, height: 1)
        view.addSubview(divider)

        // Settings sections
        addSection(
            title: "Playback",
            y: 440
        )

        // Launch at login
        addToggle(
            title: "Launch at Login",
            subtitle: "Start LiveWall when you log in",
            key: "launchAtLogin",
            y: 390
        )

        // Loop video
        addToggle(
            title: "Loop Video",
            subtitle: "Continuously loop the wallpaper video",
            key: "loopVideo",
            y: 340,
            defaultValue: true
        )

        // Mute audio
        addToggle(
            title: "Mute Audio",
            subtitle: "Play wallpaper video without sound",
            key: "muteAudio",
            y: 290,
            defaultValue: true
        )

        addSection(title: "Display", y: 240)

        // Same video all screens
        addToggle(
            title: "Same Video on All Screens",
            subtitle: "Use the same wallpaper on all connected displays",
            key: "sameVideoAllScreens",
            y: 190,
            defaultValue: true
        )

        addSection(title: "About", y: 140)

        // Version
        let version = NSTextField(
            labelWithString: "LiveWall v1.0  •  Made with ❤️"
        )
        version.font = NSFont.systemFont(ofSize: 12)
        version.textColor = .lightGray
        version.frame = NSRect(x: 40, y: 100, width: 400, height: 20)
        view.addSubview(version)
    }

    func addSection(title: String, y: CGFloat) {
        let label = NSTextField(labelWithString: title.uppercased())
        label.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = NSColor.lightGray
        label.frame = NSRect(x: 40, y: y, width: 200, height: 20)
        view.addSubview(label)

        let divider = NSBox()
        divider.boxType = .separator
        divider.frame = NSRect(x: 40, y: y - 5, width: 820, height: 1)
        view.addSubview(divider)
    }

    func addToggle(
        title: String,
        subtitle: String,
        key: String,
        y: CGFloat,
        defaultValue: Bool = false
    ) {
        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.frame = NSRect(x: 40, y: y + 18, width: 600, height: 20)
        view.addSubview(titleLabel)

        let subtitleLabel = NSTextField(labelWithString: subtitle)
        subtitleLabel.font = NSFont.systemFont(ofSize: 11)
        subtitleLabel.textColor = .lightGray
        subtitleLabel.frame = NSRect(x: 40, y: y, width: 600, height: 18)
        view.addSubview(subtitleLabel)

        let toggle = NSSwitch(
            frame: NSRect(x: 820, y: y + 10, width: 50, height: 30)
        )
        toggle.state = UserDefaults.standard.bool(forKey: key)
            ? .on
            : (defaultValue ? .on : .off)
        toggle.action = #selector(toggleChanged(_:))
        toggle.target = self
        toggle.identifier = NSUserInterfaceItemIdentifier(key)
        view.addSubview(toggle)
    }

    @objc func toggleChanged(_ sender: NSSwitch) {
        guard let key = sender.identifier?.rawValue else { return }
        UserDefaults.standard.set(sender.state == .on, forKey: key)

        // Apply settings
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
