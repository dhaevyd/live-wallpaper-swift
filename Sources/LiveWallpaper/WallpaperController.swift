import Cocoa
import AVFoundation

class WallpaperController {
    var windows: [WallpaperWindow] = []
    var currentVideoURL: URL?
    var isPlaying: Bool = false
    var isMuted: Bool = true
    var isLooping: Bool = true

    func playVideo(url: URL) {
        stopVideo()
        currentVideoURL = url
        isPlaying = true

        for screen in NSScreen.screens {
            let window = WallpaperWindow(screen: screen)
            window.playVideo(url: url, muted: isMuted, loop: isLooping)
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

    func setMuted(_ muted: Bool) {
        isMuted = muted
        windows.forEach { $0.setMuted(muted) }
    }

    func setLooping(_ looping: Bool) {
        isLooping = looping
    }

    var currentVideoName: String {
        return currentVideoURL?.lastPathComponent ?? "None"
    }
}
