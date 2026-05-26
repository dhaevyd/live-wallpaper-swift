# API Contracts for Migration

## PexelsAPI Interface
- `static let shared: PexelsAPI` - Singleton instance
- `static var configuredAPIKey: String` - Returns API key from environment or baked-in
- `static var hasAPIKey: Bool` - True if API key is available
- `func fetchFeatured(completion: @escaping (Result<[PexelsVideo], Error>) -> Void)` - Fetches featured videos
- `func searchVideos(query: String, page: Int = 1, perPage: Int = 20, completion: @escaping (Result<[PexelsVideo], Error>) -> Void)` - Searches videos
- `func fetchCategory(category: Category, completion: @escaping (Result<[PexelsVideo], Error>) -> Void)` - Fetches by category

## VideoDownloader Interface
- `static let shared: VideoDownloader` - Singleton instance
- `func downloadFolder: URL` - Returns download folder URL (~Movies/LiveWallpapers/)
- `func isDownloaded(video: PexelsVideo) -> Bool` - Checks if video is already downloaded
- `func download(video: PexelsVideo, progress: @escaping (Double) -> Void, completion: @escaping (Result<URL, Error>) -> Void)` - Downloads video with progress callback

## WallpaperController Interface
- `func playVideo(url: URL)` - Plays video as wallpaper
- `func suspendPlayback()` - Pauses wallpaper playback
- `func resumePlayback()` - Resumes wallpaper playback

## PexelsVideo Model
- `id: String` - Video ID
- `title: String` - Video title
- `user: PexelsUser` - User who uploaded
- `width: Int`, `height: Int` - Dimensions
- `duration: Int` - Duration in seconds
- `image: String` - Thumbnail URL
- `videoFiles: [PexelsVideoFile]` - Available video qualities
- `bestVideoFile: PexelsVideoFile?` - Highest quality video file

## PexelsUser Model
- `id: String` - User ID
- `name: String` - Username
- `url: String` - Profile URL

## PexelsVideoFile Model
- `link: String` - Video URL
- `width: Int`, `height: Int` - Dimensions