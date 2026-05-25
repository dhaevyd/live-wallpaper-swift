import Cocoa

class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, NSImage>()
    private var tasks: [URL: URLSessionDataTask] = [:]

    private init() {}

    func image(for url: URL, completion: @escaping (NSImage?) -> Void) {
        let key = url as NSURL
        if let image = cache.object(forKey: key) {
            DispatchQueue.main.async {
                completion(image)
            }
            return
        }

        tasks[url]?.cancel()
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            let image = data.flatMap(NSImage.init(data:))
            if let image = image {
                self.cache.setObject(image, forKey: key)
            }

            DispatchQueue.main.async {
                self.tasks[url] = nil
                completion(image)
            }
        }
        tasks[url] = task
        task.resume()
    }

    func cancelLoad(for url: URL) {
        tasks[url]?.cancel()
        tasks[url] = nil
    }
}
