import Foundation

class VideoDownloader {
    static let shared = VideoDownloader()
    private var downloadTasks: [Int: URLSessionDownloadTask] = [:]

    private init() {}

    // Download folder
    var downloadFolder: URL {
        let movies = FileManager.default.urls(
            for: .moviesDirectory,
            in: .userDomainMask
        ).first!
        let folder = movies.appendingPathComponent("LiveWallpapers")
        try? FileManager.default.createDirectory(
            at: folder,
            withIntermediateDirectories: true
        )
        return folder
    }

    // MARK: - Download Video
    func download(
        video: PexelsVideo,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        guard let videoFile = video.bestVideoFile,
              let url = URL(string: videoFile.link) else {
            return
        }

        // Check if already downloaded
        let destination = downloadFolder.appendingPathComponent(
            "\(video.id).mp4"
        )
        if FileManager.default.fileExists(atPath: destination.path) {
            completion(.success(destination))
            return
        }

        // Download
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let tempURL = tempURL else { return }

            do {
                try FileManager.default.moveItem(
                    at: tempURL,
                    to: destination
                )
                DispatchQueue.main.async {
                    completion(.success(destination))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        downloadTasks[video.id] = task
        task.resume()
    }

    // MARK: - Check If Downloaded
    func isDownloaded(video: PexelsVideo) -> Bool {
        let destination = downloadFolder.appendingPathComponent(
            "\(video.id).mp4"
        )
        return FileManager.default.fileExists(atPath: destination.path)
    }

    // MARK: - Cancel Download
    func cancelDownload(video: PexelsVideo) {
        downloadTasks[video.id]?.cancel()
        downloadTasks.removeValue(forKey: video.id)
    }
}
