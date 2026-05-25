import Cocoa
import AVFoundation

class WallpaperController {
    var windows: [WallpaperWindow] = []
    var currentVideoURL: URL?
    var isPlaying: Bool = false

    func playVideo(url: URL) {
        // Stop existing
        stopVideo()

        currentVideoURL = url
        isPlaying = true

        // Create window for each screen
        for screen in NSScreen.screens {
            let window = WallpaperWindow(screen: screen)
            window.playVideo(url: url)
            windows.append(window)
        }
    }

    func stopVideo() {
        windows.forEach { $0.stopVideo() }
        windows.removeAll()
        isPlaying = false
        currentVideoURL = nil
    }

    func pauseVideo() {
        windows.forEach { $0.pauseVideo() }
        isPlaying = false
    }

    func resumeVideo() {
        windows.forEach { $0.resumeVideo() }
        isPlaying = true
    }

    var currentVideoName: String {
        return currentVideoURL?.lastPathComponent ?? "None"
    }
}
