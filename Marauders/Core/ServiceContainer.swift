struct ServiceContainer {
    let api: APIServiceProtocol
    let feed: FeedService
//    let user: UserService
//    let article: ArticleService

    init(api: APIServiceProtocol = APIService()) {
        self.api = api
        self.feed = FeedService(api: api)
//        self.user = UserService(api: api)
//        self.article = ArticleService(api: api)
    }
}
