import Foundation

struct Category {
    let name: String
    let query: String
    let emoji: String

    static let all: [Category] = [
        Category(name: "Nature", query: "nature landscape", emoji: "🌿"),
        Category(name: "City", query: "city timelapse", emoji: "🌆"),
        Category(name: "Ocean", query: "ocean waves", emoji: "🌊"),
        Category(name: "Space", query: "space stars", emoji: "🌌"),
        Category(name: "Abstract", query: "abstract motion", emoji: "🎨"),
        Category(name: "Forest", query: "forest trees", emoji: "🌲"),
        Category(name: "Mountains", query: "mountains snow", emoji: "⛰️"),
        Category(name: "Rain", query: "rain storm", emoji: "🌧️"),
        Category(name: "Fire", query: "fire flames", emoji: "🔥"),
        Category(name: "Anime", query: "anime scenery", emoji: "⛩️"),
    ]
}
