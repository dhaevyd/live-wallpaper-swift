import Cocoa

enum WallflowAssets {
    static var statusBarIcon: NSImage? {
        image(named: "Wallflow")
    }

    static var appIcon: NSImage? {
        image(named: "Wallflow")
    }

    static var wordmark: NSImage? {
        image(named: "Wallflow Logo") ?? image(named: "Wallflow")
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
