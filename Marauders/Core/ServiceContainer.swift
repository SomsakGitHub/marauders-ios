import Foundation

protocol APIRequest {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

enum LocationAPI: APIRequest {
    case updateLocation(LocationDTO)
    case fetchVideo
    case uploadVideo
    case likeVideo(videoId: String)
    case unlikeVideo(videoId: String)

    var baseURL: URL { URL(string: "https://marauders-api.khamthan02.workers.dev/")! }

    var path: String {
        switch self {
        case .updateLocation: return "location/update"
        case .fetchVideo: return "/feed"
        case .uploadVideo: return "videos/upload"
        case .likeVideo(let videoId): return "/feeds/\(videoId)/like"
        case .unlikeVideo(let videoId): return "/feeds/\(videoId)/like"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .updateLocation, .uploadVideo, .likeVideo: return .post
        case .fetchVideo: return .get
        case .unlikeVideo: return .delete
        }
    }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var body: Data? {
        switch self {
        case .updateLocation(let dto):
            return try? JSONEncoder().encode(dto)
        case .fetchVideo:
            return nil
        case .uploadVideo:
            return nil
        case .likeVideo:
            return nil
        case .unlikeVideo:
            return nil
        }
    }
}

//struct ServiceContainer {
//    let api: APIServiceProtocol
////    let feed: FeedService
////    let user: UserService
////    let article: ArticleService
//
//    init(api: APIServiceProtocol = APIService()) {
//        self.api = api
////        self.feed = FeedService(api: api)
////        self.user = UserService(api: api)
////        self.article = ArticleService(api: api)
//    }
//}
