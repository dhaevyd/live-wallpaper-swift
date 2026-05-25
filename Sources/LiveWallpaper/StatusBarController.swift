import Cocoa

class StatusBarController {
    var statusItem: NSStatusItem?
    var wallpaperController: WallpaperController
    var openMainWindow: () -> Void

    init(
        wallpaperController: WallpaperController,
        openMainWindow: @escaping () -> Void
    ) {
        self.wallpaperController = wallpaperController
        self.openMainWindow = openMainWindow
        setupStatusBar()
    }

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "play.rectangle.fill",
                accessibilityDescription: "Live Wallpaper"
            )
        }
        updateMenu()
    }

    func updateMenu() {
        let menu = NSMenu()

        // Now playing
        let playingItem = NSMenuItem(
            title: "Now Playing: \(wallpaperController.currentVideoName)",
            action: nil,
            keyEquivalent: ""
        )
        playingItem.isEnabled = false
        menu.addItem(playingItem)

        menu.addItem(NSMenuItem.separator())

        // Open app
        menu.addItem(NSMenuItem(
            title: "Open LiveWallpaper",
            action: #selector(openApp),
            keyEquivalent: "o"
        ).also { $0.target = self })

        // Change video
        menu.addItem(NSMenuItem(
            title: "Change Video",
            action: #selector(changeVideo),
            keyEquivalent: "v"
        ).also { $0.target = self })

        menu.addItem(NSMenuItem.separator())

        // Pause/Resume
        if wallpaperController.isPlaying {
            menu.addItem(NSMenuItem(
                title: "Pause",
                action: #selector(pauseVideo),
                keyEquivalent: "p"
            ).also { $0.target = self })
        } else {
            menu.addItem(NSMenuItem(
                title: "Resume",
                action: #selector(resumeVideo),
                keyEquivalent: "r"
            ).also { $0.target = self })
        }

        // Stop
        menu.addItem(NSMenuItem(
            title: "Stop",
            action: #selector(stopVideo),
            keyEquivalent: "s"
        ).also { $0.target = self })

        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        ).also { $0.target = self })

        statusItem?.menu = menu
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

// Helper
extension NSMenuItem {
    func also(_ block: (NSMenuItem) -> Void) -> NSMenuItem {
        block(self)
        return self
    }
}
