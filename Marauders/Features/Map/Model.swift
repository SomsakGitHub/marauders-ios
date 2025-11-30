import Foundation

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
}

struct LocationDTO: Codable {
    let latitude: Double
    let longitude: Double
    let accuracy: Double
    let timestamp: Date
}

//
//import SwiftUI
//import Combine
//import CoreLocation
//import MapKit
//import Foundation
//
//final class MapViewModel: ObservableObject {
//
//    // MARK: - Published
//    @Published var status: CLAuthorizationStatus = .notDetermined
//    @Published var userLocation: CLLocation?
//    @Published var region: MKCoordinateRegion
//    @Published var selectedCoordinate: CLLocationCoordinate2D?
//    @Published var isMapReady = false
//    @Published var showOnboarding = true
//    private let sendLocationUseCase: SendLocationUseCaseProtocol
//
//    private let locationService: LocationServiceProtocol
//    private let useCase: MapUseCaseProtocol
//    private var cancellables = Set<AnyCancellable>()
//
//    init(
//        locationService: LocationServiceProtocol = LocationService(),
//        useCase: MapUseCaseProtocol = MapUseCase(),
//        sendLocationUseCase: SendLocationUseCaseProtocol
//    ) {
//        self.locationService = locationService
//        self.useCase = useCase
//        self.sendLocationUseCase = sendLocationUseCase
//        
//        region = useCase.updateRegion(from: nil)
//
//        bind()
//    }
//
//    private func bind() {
//        locationService.objectWillChange
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//
//                self.status = self.locationService.authorizationStatus
//
//                if let location = self.locationService.userLocation {
//                    self.userLocation = location
//                    self.region = self.useCase.updateRegion(from: location)
//                    
//                    Task {
//                        do {
//                            let dto = LocationDTO(latitude: location.coordinate.latitude,
//                                                  longitude: location.coordinate.longitude,
//                                                  accuracy: location.horizontalAccuracy,
//                                                  timestamp: Date())
//                            try await self.sendLocationUseCase.execute(dto: dto)
//                        } catch {
//                            // handle or log (we rely on AuthInterceptor to refresh token)
//                            debugPrint("Send location failed: \(error)")
//                        }
//                    }
//                }
//            }
//            .store(in: &cancellables)
//    }
//
//    func requestPermission() {
//        locationService.requestAuthorization()
//    }
//
//    func onMapReady() { isMapReady = true }
//    
//    func onUserTap(_ coordinate: CLLocationCoordinate2D) {
//        selectedCoordinate = coordinate
//    }
//}
//
//protocol MapUseCaseProtocol {
//    func updateRegion(from location: CLLocation?) -> MKCoordinateRegion
//}
//
//struct MapUseCase: MapUseCaseProtocol {
//    func updateRegion(from location: CLLocation?) -> MKCoordinateRegion {
//        guard let location = location else {
//            return MKCoordinateRegion(
//                center: CLLocationCoordinate2D(latitude: 13.63164, longitude: 13.63164),
//                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//            )
//        }
//
//        return MKCoordinateRegion(
//            center: location.coordinate,
//            span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
//        )
//    }
//}
//
//public final class MapViewDIContainer {
//    public static let shared = MapViewDIContainer()
//
//    private init() {}
//    
//     func makeSendLocationUseCase() -> SendLocationUseCaseProtocol {
//        DefaultSendLocationUseCase(repo: makeMapRepository())
//    }
//    
//     func makeMapRepository() -> LocationRepositoryProtocol {
////         LocationNetworkService(client: <#T##any NetworkClientProtocol#>)
//    }
//    
//     func makeMapViewModel() -> MapViewModel {
//        MapViewModel(sendLocationUseCase: makeSendLocationUseCase())
//    }
//}
//
//protocol SendLocationUseCaseProtocol {
//    func execute(dto: LocationDTO) async throws
//}
//
//final class DefaultSendLocationUseCase: SendLocationUseCaseProtocol {
//    private let repo: LocationRepositoryProtocol
//
//    init(repo: LocationRepositoryProtocol) {
//        self.repo = repo
//    }
//
//    func execute(dto: LocationDTO) async throws {
//        try await repo.updateLocation(dto)
//    }
//}
//
//protocol LocationRepositoryProtocol {
//    func updateLocation(_ dto: LocationDTO) async throws
//}
//
//final class LocationRepository: LocationRepositoryProtocol {
//    private let service: LocationNetworkServiceProtocol
//
//    init(service: LocationNetworkServiceProtocol) {
//        self.service = service
//    }
//
//    func updateLocation(_ dto: LocationDTO) async throws {
//        try await service.sendLocation(dto)
//    }
//}
//
//protocol LocationNetworkServiceProtocol {
//    func sendLocation(_ dto: LocationDTO) async throws
//}
//
//final class LocationNetworkService: LocationNetworkServiceProtocol {
//    private let client: NetworkClientProtocol
//
//    init(client: NetworkClientProtocol) {
//        self.client = client
//    }
//
//    func sendLocation(_ dto: LocationDTO) async throws {
//        try await client.sendVoid(LocationAPI.update(dto))
//    }
//}
//
//// MARK: - APIRequest (actor-safe)
//protocol APIRequest: URLRequestConvertible, Sendable {
//     var baseURL: URL { get }
//     var path: String { get }
//     var method: HTTPMethod { get }
//     var headers: HTTPHeaders? { get }
//     var queryItems: [URLQueryItem]? { get }
//     var body: Encodable? { get }    // prefer Data? in high-perf code
//}
//
//enum JSONHelper {
//     static func encode(_ value: Encodable) throws -> Data {
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//
//        struct Wrapper: Encodable {
//            let value: Encodable
//            func encode(to encoder: Encoder) throws {
//                try value.encode(to: encoder)
//            }
//        }
//        return try encoder.encode(Wrapper(value: value))
//    }
//}
//
//extension APIRequest {
//     func asURLRequest() throws -> URLRequest {
//        var url = baseURL.appendingPathComponent(path)
//
//        if let items = queryItems,
//           var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
//            comps.queryItems = items
//            if let u = comps.url { url = u }
//        }
//
//        var req = URLRequest(url: url)
//        req.httpMethod = method.rawValue
//
//        headers?.forEach { req.setValue($0.value, forHTTPHeaderField: $0.name) }
//
//        if let body = body {
//            req.httpBody = try JSONHelper.encode(body)
//        }
//        return req
//    }
//}
//
//// MARK: - RequestBuilder (plain struct, not actor)
//struct RequestBuilder {
//    func build(_ request: APIRequest) throws -> URLRequest {
//        try request.asURLRequest()
//    }
//}
//
////// helper to encode an Encodable as Data
////fileprivate extension JSONEncoder {
////    static func encodeAny<T: Encodable>(_ value: T) throws -> Data {
////        let encoder = JSONEncoder()
////        encoder.dateEncodingStrategy = .iso8601
////        return try encoder.encode(value)
////    }
////}
////
////fileprivate extension JSONEncoder {
////    func encodeAnyEncodable(_ value: Encodable) throws -> Data {
////        // Generic wrapper trick
////        struct ErasedEncodable: Encodable {
////            let wrapped: Encodable
////            func encode(to encoder: Encoder) throws {
////                try wrapped.encode(to: encoder)
////            }
////        }
////        return try JSONEncoder().encode(ErasedEncodable(wrapped: value))
////    }
////}
////
////// Simple convenience (avoids the ErasedEncodable complexity when possible)
////extension JSONEncoder {
////    static func encode<T: Encodable>(_ value: T) throws -> Data {
////        let encoder = JSONEncoder()
////        encoder.dateEncodingStrategy = .iso8601
////        return try encoder.encode(value)
////    }
////}
////
//struct LocationDTO: Codable {
//    let latitude: Double
//    let longitude: Double
//    let accuracy: Double
//    let timestamp: Date
//}
//
//// MARK: - concrete endpoint (value, immutable)
//enum LocationAPI: APIRequest {
//    case update(LocationDTO)
//
//    var baseURL: URL { URL(string: "https://api.example.com")! } // nonisolated by protocol
//    var path: String {
//        switch self { case .update: return "/location/update" }
//    }
//    var method: HTTPMethod {
//        switch self { case .update: return .post }
//    }
//    var headers: HTTPHeaders? { ["Content-Type": "application/json"] }
//    var queryItems: [URLQueryItem]? { nil }
//    var body: Encodable? {
//        switch self { case .update(let dto): return dto }
//    }
//}
////
////enum APIError: Error {
////    case invalidResponse
////    case httpError(code: Int, data: Data?)
////    case decodingError(Error)
////    case underlying(Error)
////    case unauthorized
////    case cancelled
////    case unknown
////}
////
////final class NetworkLogger: EventMonitor {
////    let queue = DispatchQueue(label: "com.example.networklogger")
////
////    func requestDidResume(_ request: Request) {
////        debugPrint("➡️ Request: \(request.description)")
////    }
////
////    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
////        debugPrint("⬅️ Response: \(response.debugDescription)")
////    }
////}
////
//protocol NetworkClientProtocol {
//    func send<T: Decodable>(_ request: APIRequest) async throws -> T
//    func sendVoid(_ request: APIRequest) async throws
//}
//
//final class NetworkClient: NetworkClientProtocol {
//    private let session: Session
//    private let decoder: JSONDecoder
//
//    init(session: Session = NetworkClient.defaultSession(),
//         decoder: JSONDecoder = NetworkClient.defaultDecoder()) {
//        self.session = session
//        self.decoder = decoder
//    }
//
//    static func defaultDecoder() -> JSONDecoder {
//        let d = JSONDecoder()
//        d.dateDecodingStrategy = .iso8601
//        return d
//    }
//
//    static func defaultSession(interceptor: RequestInterceptor? = nil,
//                               eventMonitors: [EventMonitor] = []) -> Session {
//        let config = URLSessionConfiguration.default
//        config.timeoutIntervalForRequest = 30
//        config.waitsForConnectivity = true
//        return Session(configuration: config, interceptor: interceptor, eventMonitors: eventMonitors)
//    }
//
//    func send<T: Decodable>(_ request: APIRequest) async throws -> T {
//        let builder = RequestBuilder()
//        let urlRequest = try await builder.build(request)
//
//        let dataRequest = session.request(urlRequest)
//        let result = await dataRequest.serializingData().result
//
//        switch result {
//        case .success(let data):
//            do {
//                return try decoder.decode(T.self, from: data)
//            } catch {
////                throw APIError.decodingError(error)
//            }
//
//        case .failure(let afError):
//            let http = dataRequest.response?.statusCode
////            if http == 401 { throw APIError.unauthorized }
////            throw mapAFError(error: afError, data: nil, response: dataRequest.response)
//        }
//    }
//
//
//    func sendVoid(_ request: APIRequest) async throws {
//        let builder = RequestBuilder()
//        let urlRequest = try await builder.build(request)
//        let dataRequest = session.request(urlRequest)
//        let response = await dataRequest.serializingData().response
//
//        if let error = response.error {
////            throw mapAFError(error: error, data: response.data, response: response.response)
//        }
//
//        guard let http = response.response, (200...299).contains(http.statusCode) else {
////            throw APIError.httpError(code: response.response?.statusCode ?? -1, data: response.data)
//        }
//    }
//
////    private func mapAFError(error: AFError, data: Data?, response: HTTPURLResponse?) -> Error {
////        if error.isExplicitlyCancelledError { return APIError.cancelled }
////        if let status = response?.statusCode {
////            if status == 401 { return APIError.unauthorized }
////            return APIError.httpError(code: status, data: data)
////        }
////        return APIError.underlying(error)
////    }
//}
//
////protocol LocationNetworkServiceProtocol {
////    func sendLocation(_ dto: LocationDTO) async throws
////}
////
////final class LocationNetworkService: LocationNetworkServiceProtocol {
////    private let client: NetworkClientProtocol
////
////    init(client: NetworkClientProtocol = NetworkClient()) {
////        self.client = client
////    }
////
////    func sendLocation(_ dto: LocationDTO) async throws {
////        try await client.sendVoid(LocationAPI.update(dto))
////    }
////}
//
////protocol LocationRepositoryProtocol {
////    func updateLocation(_ dto: LocationDTO) async throws
////}
////
////final class LocationRepository: LocationRepositoryProtocol {
////    private let service: LocationNetworkServiceProtocol
////
////    init(service: LocationNetworkServiceProtocol = LocationNetworkService()) {
////        self.service = service
////    }
////
////    func updateLocation(_ dto: LocationDTO) async throws {
////        try await service.sendLocation(dto)
////    }
////}
//
////protocol SendLocationUseCaseProtocol {
////    func execute(dto: LocationDTO) async throws
////}
////
////final class SendLocationUseCase: SendLocationUseCaseProtocol {
////    private let repo: LocationRepositoryProtocol
////
////    init(repo: LocationRepositoryProtocol = LocationRepository()) {
////        self.repo = repo
////    }
////
////    func execute(dto: LocationDTO) async throws {
////        try await repo.updateLocation(dto)
////    }
////}
//
//
//
//
//
