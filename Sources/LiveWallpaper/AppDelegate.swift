import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var wallpaperController: WallpaperController?
    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.applicationIconImage = WallflowAssets.appIcon

        // Create default wallpaper folder
        createDefaultFolder()

        // Start wallpaper controller
        wallpaperController = WallpaperController()

        // Start status bar
        statusBarController = StatusBarController(
            wallpaperController: wallpaperController!,
            openMainWindow: { self.openMainWindow() }
        )

        // Open main window on first launch
        openMainWindow()
    }

    func openMainWindow() {
        if mainWindowController == nil {
            mainWindowController = MainWindowController(
                wallpaperController: wallpaperController!
            )
        }
        mainWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func createDefaultFolder() {
        let folder = defaultWallpaperFolder()
        try? FileManager.default.createDirectory(
            at: folder,
            withIntermediateDirectories: true
        )
    }

    func defaultWallpaperFolder() -> URL {
        let movies = FileManager.default.urls(
            for: .moviesDirectory,
            in: .userDomainMask
        ).first!
        return movies.appendingPathComponent("LiveWallpapers")
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        return false
    }
}
