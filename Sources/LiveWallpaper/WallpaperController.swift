import Cocoa
import AVFoundation

final class WallpaperController {
    static let shared = WallpaperController()

    private var windows: [CGDirectDisplayID: WallpaperWindow] = [:]
    private var urls: [CGDirectDisplayID: URL] = [:]

    func play(url: URL, on screen: NSScreen) {
        let id = displayID(for: screen)
        windows[id]?.stopVideo()
        let win = WallpaperWindow(screen: screen)
        win.playVideo(url: url)
        windows[id] = win
        urls[id] = url
    }

    func stop(screen: NSScreen) {
        let id = displayID(for: screen)
        windows[id]?.stopVideo()
        windows.removeValue(forKey: id)
        urls.removeValue(forKey: id)
    }

    func stopAll() {
        windows.values.forEach { $0.stopVideo() }
        windows.removeAll()
        urls.removeAll()
    }

    func currentURL(for screen: NSScreen) -> URL? {
        urls[displayID(for: screen)]
    }

    private func displayID(for screen: NSScreen) -> CGDirectDisplayID {
        (screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value ?? 0
    }
}
