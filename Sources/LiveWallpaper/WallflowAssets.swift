import Cocoa

enum WallflowAssets {
    static var statusBarIcon: NSImage? {
        let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        return image(named: isDark ? "light-status-logo" : "dark-status-logo") ?? image(named: "app-logo")
    }

    static var appIcon: NSImage? {
        image(named: "app-logo")
    }

    static var wordmark: NSImage? {
        image(named: "Wallflow Logo") ?? image(named: "app-logo")
    }

    static func image(named name: String) -> NSImage? {
        if let image = NSImage(named: NSImage.Name(name)) {
            return image
        }
        if let url = Bundle.main.url(forResource: name, withExtension: "png") {
            return NSImage(contentsOf: url)
        }

        let localURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Images")
            .appendingPathComponent("\(name).png")
        return NSImage(contentsOf: localURL)
    }
}
