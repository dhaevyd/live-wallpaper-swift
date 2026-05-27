import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: StatusBarController!
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBar = StatusBarController(
            onShow: { [weak self] in self?.showWindow() },
            onStopAll: { [weak self] in
                WallpaperController.shared.stopAll()
                (self?.window?.contentViewController as? ScreenPickerViewController)?.reload()
            }
        )
        showWindow()
    }

    func showWindow() {
        if let w = window {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        let vc = ScreenPickerViewController()
        let win = NSWindow(contentViewController: vc)
        win.title = "Wallflow"
        win.styleMask = [.titled, .closable, .miniaturizable]
        win.isReleasedWhenClosed = false
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window = win
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}
