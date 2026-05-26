import Foundation

struct Wallpaper: Identifiable {
    let id: Int
    let title: String
    let photographer: String
    let resolution: String
    let duration: Int
    let imageURL: URL?
    let videoURL: URL?
    let isPro: Bool

    var metaLine: String {
        var parts: [String] = []
        if !resolution.isEmpty { parts.append(resolution) }
        if duration > 0 { parts.append("\(duration)s") }
        return parts.joined(separator: "  ·  ")
    }

    // MARK: - Mock data for development phases 1–5

    static let placeholder = Wallpaper(
        id: 0,
        title: "Abandoned Train Station Scenic View",
        photographer: "John Doe",
        resolution: "3840 × 2160",
        duration: 63,
        imageURL: nil,
        videoURL: nil,
        isPro: false
    )

    static let mockThumbnails: [Wallpaper] = (1...7).map { i in
        Wallpaper(
            id: i,
            title: "Wallpaper \(i)",
            photographer: "Photographer \(i)",
            resolution: "1920 × 1080",
            duration: 30,
            imageURL: nil,
            videoURL: nil,
            isPro: i % 3 == 0
        )
    }

    static let mockGallery: [Wallpaper] = (100...111).map { i in
        Wallpaper(
            id: i,
            title: "Scene \(i - 99)",
            photographer: "Artist \(i - 99)",
            resolution: i % 2 == 0 ? "3840 × 2160" : "2560 × 1440",
            duration: 20 + (i % 5) * 10,
            imageURL: nil,
            videoURL: nil,
            isPro: i % 4 == 0
        )
    }
}
