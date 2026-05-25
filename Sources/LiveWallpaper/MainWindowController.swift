import Cocoa

class MainWindowController: NSWindowController {
    var wallpaperController: WallpaperController
    var videoGridViewController: VideoGridViewController?

    init(wallpaperController: WallpaperController) {
        self.wallpaperController = wallpaperController

        // Create main window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 620),
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
        window.title = "Live Wallpaper"
        window.center()
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = NSColor(
            red: 0.08,
            green: 0.08,
            blue: 0.08,
            alpha: 1.0
        )

        super.init(window: window)

        setupContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupContent() {
        videoGridViewController = VideoGridViewController(
            wallpaperController: wallpaperController
        )
        self.window?.contentViewController = videoGridViewController
    }

    func windowWillClose(_ notification: Notification) {
        // Keep running in background
        NSApp.setActivationPolicy(.accessory)
    }
}
