import Cocoa

class StatusBarController {
    private var statusItem: NSStatusItem!
    private let onShow: () -> Void
    private let onStopAll: () -> Void

    init(onShow: @escaping () -> Void, onStopAll: @escaping () -> Void) {
        self.onShow = onShow
        self.onStopAll = onStopAll
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let btn = statusItem.button {
            btn.image = NSImage(systemSymbolName: "play.rectangle.fill", accessibilityDescription: "Wallflow")
            btn.toolTip = "Wallflow"
        }
        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "Open Wallflow", action: #selector(show), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Stop All Wallpapers", action: #selector(stopAll), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
    }

    @objc private func show() { onShow() }
    @objc private func stopAll() { onStopAll() }
}
