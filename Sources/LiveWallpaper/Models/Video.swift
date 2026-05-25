import Foundation

struct PexelsResponse: Codable {
    let videos: [PexelsVideo]
    let totalResults: Int
    let page: Int
    let perPage: Int

    enum CodingKeys: String, CodingKey {
        case videos
        case totalResults = "total_results"
        case page
        case perPage = "per_page"
    }
}

struct PexelsVideo: Codable, Identifiable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let image: String
    let duration: Int
    let user: PexelsUser
    let videoFiles: [PexelsVideoFile]

    enum CodingKeys: String, CodingKey {
        case id, width, height, url, image, duration, user
        case videoFiles = "video_files"
    }

    // Get best quality video file
    var bestVideoFile: PexelsVideoFile? {
        return videoFiles
            .filter { $0.quality == "hd" || $0.quality == "sd" }
            .sorted { $0.width ?? 0 > $1.width ?? 0 }
            .first
    }

    var title: String {
        return "Video by \(user.name)"
    }
}

struct PexelsUser: Codable {
    let id: Int
    let name: String
    let url: String
}

struct PexelsVideoFile: Codable {
    let id: Int
    let quality: String
    let fileType: String
    let width: Int?
    let height: Int?
    let link: String

    enum CodingKeys: String, CodingKey {
        case id, quality, width, height, link
        case fileType = "file_type"
    }
}
