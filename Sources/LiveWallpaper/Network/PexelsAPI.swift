import Foundation

enum PexelsAPIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case noData
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "PEXELS_API_KEY is missing."
        case .invalidURL:
            return "The Pexels request URL is invalid."
        case .noData:
            return "Pexels returned no response data."
        case .httpStatus(let status):
            return "Pexels returned HTTP status \(status)."
        }
    }
}

class PexelsAPI {
    static let shared = PexelsAPI()

    static var configuredAPIKey: String {
        let runtimeKey = ProcessInfo.processInfo.environment["PEXELS_API_KEY"] ?? ""
        return runtimeKey.isEmpty ? AppConfig.bakedPexelsAPIKey : runtimeKey
    }

    static var hasAPIKey: Bool {
        !configuredAPIKey.isEmpty
    }

    private let apiKey = PexelsAPI.configuredAPIKey
    private let baseURL = "https://api.pexels.com/videos"

    private init() {}

    // MARK: - Fetch Featured Videos
    func fetchFeatured(
        completion: @escaping (Result<[PexelsVideo], Error>) -> Void
    ) {
        fetch(
            endpoint: "/popular",
            params: ["per_page": "20"],
            completion: completion
        )
    }

    // MARK: - Search Videos
    func searchVideos(
        query: String,
        page: Int = 1,
        perPage: Int = 20,
        completion: @escaping (Result<[PexelsVideo], Error>) -> Void
    ) {
        fetch(
            endpoint: "/search",
            params: [
                "query": query,
                "per_page": "\(perPage)",
                "page": "\(page)",
                "orientation": "landscape"
            ],
            completion: completion
        )
    }

    // MARK: - Fetch By Category
    func fetchCategory(
        category: Category,
        completion: @escaping (Result<[PexelsVideo], Error>) -> Void
    ) {
        searchVideos(
            query: category.query,
            completion: completion
        )
    }

    // MARK: - Core Fetch
    private func fetch(
        endpoint: String,
        params: [String: String],
        completion: @escaping (Result<[PexelsVideo], Error>) -> Void
    ) {
        var components = URLComponents(
            string: baseURL + endpoint
        )!
        components.queryItems = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }

        guard !apiKey.isEmpty else {
            DispatchQueue.main.async {
                completion(.failure(PexelsAPIError.missingAPIKey))
            }
            return
        }

        guard let url = components.url else {
            DispatchQueue.main.async {
                completion(.failure(PexelsAPIError.invalidURL))
            }
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    completion(.failure(PexelsAPIError.httpStatus(httpResponse.statusCode)))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(PexelsAPIError.noData))
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(
                    PexelsResponse.self,
                    from: data
                )
                DispatchQueue.main.async {
                    completion(.success(response.videos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
