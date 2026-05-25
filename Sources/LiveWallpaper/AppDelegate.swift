import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var wallpaperWindow: WallpaperWindow?
    var controlWindow: ControlWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Launch control panel
        controlWindow = ControlWindow()
        controlWindow?.showWindow(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool {
        return true
    }
}
