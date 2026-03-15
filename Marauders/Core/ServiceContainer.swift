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

    var baseURL: URL { URL(string: "http://192.168.1.164:8080/v1/")! }

    var path: String {
        switch self {
        case .updateLocation: return "location/update"
        case .fetchVideo: return "videos/feed"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .updateLocation: return .post
        case .fetchVideo: return .get
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
