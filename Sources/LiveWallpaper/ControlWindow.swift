import Cocoa

class ControlWindow: NSWindowController {
    var wallpaperWindow: WallpaperWindow?

    convenience init() {
        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Live Wallpaper"
        window.center()
        self.init(window: window)
        setupUI()
    }

    func setupUI() {
        guard let window = self.window else { return }
        let view = window.contentView!

        // Dark background
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(
            red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0
        ).cgColor

        // Title label
        let title = NSTextField(labelWithString: "Live Wallpaper")
        title.font = NSFont.boldSystemFont(ofSize: 24)
        title.textColor = .white
        title.frame = NSRect(x: 0, y: 220, width: 400, height: 40)
        title.alignment = .center
        view.addSubview(title)

        // Status label
        let status = NSTextField(labelWithString: "No video selected")
        status.font = NSFont.systemFont(ofSize: 14)
        status.textColor = .gray
        status.frame = NSRect(x: 0, y: 180, width: 400, height: 30)
        status.alignment = .center
        status.tag = 100
        view.addSubview(status)

        // Pick video button
        let pickBtn = NSButton(
            title: "Pick Video",
            target: self,
            action: #selector(pickVideo)
        )
        pickBtn.frame = NSRect(x: 100, y: 120, width: 200, height: 40)
        pickBtn.bezelStyle = .rounded
        view.addSubview(pickBtn)

        // Stop button
        let stopBtn = NSButton(
            title: "Stop Wallpaper",
            target: self,
            action: #selector(stopWallpaper)
        )
        stopBtn.frame = NSRect(x: 100, y: 60, width: 200, height: 40)
        stopBtn.bezelStyle = .rounded
        view.addSubview(stopBtn)
    }

    @objc func pickVideo() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["mp4", "mov", "avi", "mkv"]
        panel.allowsMultipleSelection = false

        panel.begin { response in
            if response == .OK, let url = panel.url {
                // Update status
                if let status = self.window?.contentView?
                    .viewWithTag(100) as? NSTextField {
                    status.stringValue = "Playing: \(url.lastPathComponent)"
                }
                // Play video
                if self.wallpaperWindow == nil {
                    self.wallpaperWindow = WallpaperWindow()
                }
                self.wallpaperWindow?.playVideo(url: url)
            }
        }
    }

    @objc func stopWallpaper() {
        wallpaperWindow?.stopVideo()
        if let status = self.window?.contentView?
            .viewWithTag(100) as? NSTextField {
            status.stringValue = "Stopped"
        }
    }
}
