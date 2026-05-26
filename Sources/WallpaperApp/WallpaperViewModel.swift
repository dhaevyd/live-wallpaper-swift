import Foundation
import Combine

@MainActor
final class WallpaperViewModel: ObservableObject {

    // MARK: - Home

    @Published var featured: Wallpaper = .placeholder
    @Published var featuredThumbnails: [Wallpaper] = Wallpaper.mockThumbnails
    @Published var curatedPicks: [Wallpaper] = []
    @Published var isLoadingHome = false
    @Published var homeError: String? = nil

    // MARK: - Explore

    @Published var exploreResults: [Wallpaper] = []
    @Published var isLoadingExplore = false
    @Published var exploreError: String? = nil
    @Published var selectedCategory: Category? = nil

    // MARK: - Fetch home feed

    func fetchHome() {
        guard PexelsAPI.hasAPIKey else {
            homeError = "PEXELS_API_KEY not configured. Set the env var or build via GitHub Actions."
            return
        }
        isLoadingHome = true
        homeError = nil

        PexelsAPI.shared.fetchFeatured { [weak self] result in
            guard let self else { return }
            self.isLoadingHome = false
            switch result {
            case .success(let videos):
                guard !videos.isEmpty else {
                    self.homeError = "No featured wallpapers returned."
                    return
                }
                self.featured = Wallpaper(from: videos[0])
                self.featuredThumbnails = Array(videos.prefix(8)).map(Wallpaper.init(from:))
                self.curatedPicks = videos.map(Wallpaper.init(from:))
            case .failure(let error):
                self.homeError = error.localizedDescription
            }
        }
    }

    // MARK: - Fetch explore category

    func fetchCategory(_ category: Category) {
        guard PexelsAPI.hasAPIKey else {
            exploreError = "PEXELS_API_KEY not configured."
            return
        }
        selectedCategory = category
        isLoadingExplore = true
        exploreError = nil

        PexelsAPI.shared.fetchCategory(category: category) { [weak self] result in
            guard let self else { return }
            self.isLoadingExplore = false
            switch result {
            case .success(let videos):
                self.exploreResults = videos.map(Wallpaper.init(from:))
            case .failure(let error):
                self.exploreError = error.localizedDescription
            }
        }
    }

    // MARK: - Search

    func search(query: String) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, PexelsAPI.hasAPIKey else { return }
        selectedCategory = nil
        isLoadingExplore = true
        exploreError = nil

        PexelsAPI.shared.searchVideos(query: q) { [weak self] result in
            guard let self else { return }
            self.isLoadingExplore = false
            switch result {
            case .success(let videos):
                self.exploreResults = videos.map(Wallpaper.init(from:))
            case .failure(let error):
                self.exploreError = error.localizedDescription
            }
        }
    }
}
