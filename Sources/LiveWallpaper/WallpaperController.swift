import Cocoa
import AVFoundation

class WallpaperController {
    var windows: [WallpaperWindow] = []
    var currentVideoURL: URL?
    var isPlaying: Bool = false
<<<<<<< HEAD
    var isMuted: Bool = true
    var isLooping: Bool = true

    func playVideo(url: URL) {
        stopVideo()
=======

    func playVideo(url: URL) {
        // Stop existing
        stopVideo()

>>>>>>> 9db167e02c9263e86a3bc5568df9de03a1da5f2b
        currentVideoURL = url
        isPlaying = true

        // Create window for each screen
        for screen in NSScreen.screens {
            let window = WallpaperWindow(screen: screen)
<<<<<<< HEAD
            window.playVideo(url: url, muted: isMuted, loop: isLooping)
=======
            window.playVideo(url: url)
>>>>>>> 9db167e02c9263e86a3bc5568df9de03a1da5f2b
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

<<<<<<< HEAD
    func setMuted(_ muted: Bool) {
        isMuted = muted
        windows.forEach { $0.setMuted(muted) }
    }

    func setLooping(_ looping: Bool) {
        isLooping = looping
    }

=======
>>>>>>> 9db167e02c9263e86a3bc5568df9de03a1da5f2b
    var currentVideoName: String {
        return currentVideoURL?.lastPathComponent ?? "None"
    }
}
