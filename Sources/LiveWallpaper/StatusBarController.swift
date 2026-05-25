import Cocoa

class StatusBarController {
    var statusItem: NSStatusItem?
    var wallpaperController: WallpaperController
    var openMainWindow: () -> Void

    init(wallpaperController: WallpaperController, openMainWindow: @escaping () -> Void) {
        self.wallpaperController = wallpaperController
        self.openMainWindow = openMainWindow
        setupStatusBar()
    }

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            if let image = WallflowAssets.statusBarIcon {
                image.size = NSSize(width: 18, height: 18)
                image.isTemplate = false
                button.image = image
                button.title = ""
                statusItem?.length = 28
            } else {
                let font = NSFont(name: "Cisnero", size: 18) ?? NSFont.systemFont(ofSize: 18, weight: .black)
                button.attributedTitle = NSAttributedString(
                    string: "W",
                    attributes: [.font: font, .foregroundColor: WallflowTheme.accent]
                )
            }
            button.toolTip = "Wallflow"
        }
        updateMenu()
    }

    func updateMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let title = NSMenuItem(title: "Wallflow", action: nil, keyEquivalent: "")
        title.isEnabled = false
        menu.addItem(title)

        let playingItem = NSMenuItem(title: "Now Playing: \(wallpaperController.currentVideoName)", action: nil, keyEquivalent: "")
        playingItem.isEnabled = false
        menu.addItem(playingItem)
        menu.addItem(.separator())

        menu.addItem(item("Open Wallflow", #selector(openApp), "o"))
        menu.addItem(item("Change Wallpaper", #selector(changeVideo), "v"))
        menu.addItem(.separator())

        if wallpaperController.isPlaying {
            menu.addItem(item("Pause", #selector(pauseVideo), "p"))
        } else {
            menu.addItem(item("Resume", #selector(resumeVideo), "r"))
        }
        menu.addItem(item("Stop", #selector(stopVideo), "s"))
        menu.addItem(.separator())
        menu.addItem(item("Quit Wallflow", #selector(quitApp), "q"))
        statusItem?.menu = menu
    }

    private func item(_ title: String, _ action: Selector, _ key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        item.isEnabled = true
        return item
    }

    @objc func openApp() {
        openMainWindow()
        updateMenu()
    }

    @objc func changeVideo() {
        openMainWindow()
        updateMenu()
    }

    @objc func pauseVideo() {
        wallpaperController.pauseVideo()
        updateMenu()
    }

    @objc func resumeVideo() {
        wallpaperController.resumeVideo()
        updateMenu()
    }

    @objc func stopVideo() {
        wallpaperController.stopVideo()
        updateMenu()
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}
