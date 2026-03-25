struct UserProfile: Identifiable, Codable {
    let id: String
    let name: String
    let username: String
    let bio: String
    let avatarURL: String
    let followers: Int
    let following: Int
    let posts: Int
    let status: Bool
}

import Foundation
import Combine
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var error: String?
    
    func fetchProfile() async {
        isLoading = true
        error = nil
        
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // mock data
            self.profile = UserProfile(
                id: "1",
                name: "SomSak",
                username: "@somsak",
                bio: "iOS Developer 🚀",
                avatarURL: "https://i.pravatar.cc/300",
                followers: 1200,
                following: 300,
                posts: 45,
                status: true
            )
            
        } catch {
            self.error = "Failed to load profile"
        }
        
        isLoading = false
    }
}

struct ProfileView: View {
    
    @StateObject private var viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                
            } else if let profile = viewModel.profile {
                content(profile)
                
            } else if let error = viewModel.error {
                Text(error)
            }
        }
        .task {
            if viewModel.profile == nil {
                await viewModel.fetchProfile()
            }
        }
    }
    
    private func content(_ profile: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                
                avatarSection(profile)
                infoSection(profile)
                statsSection(profile)
                actionSection()
                
            }
            .padding()
        }
    }
}

#Preview("Loaded State") {
    ProfileView(viewModel: MockProfileViewModel())
}

private func avatarSection(_ profile: UserProfile) -> some View {
    AsyncImage(url: URL(string: profile.avatarURL)) { image in
        image.resizable()
    } placeholder: {
        ProgressView()
    }
    .frame(width: 100, height: 100)
    .clipShape(Circle())
}

private func infoSection(_ profile: UserProfile) -> some View {
    VStack(spacing: 4) {
        Text(profile.name)
            .font(.title2)
            .fontWeight(.bold)
        
        Text(profile.username)
            .foregroundColor(.gray)
        
        Text(profile.bio)
            .font(.subheadline)
        
        Text("สถานะพร้อม: \(profile.status ? "Yes" : "No")")
            .font(.subheadline)
    }
}

private func statsSection(_ profile: UserProfile) -> some View {
    HStack(spacing: 24) {
        statItem(value: profile.posts, title: "Posts")
        statItem(value: profile.followers, title: "Followers")
        statItem(value: profile.following, title: "Following")
    }
}

private func statItem(value: Int, title: String) -> some View {
    VStack {
        Text("\(value)")
            .font(.headline)
        Text(title)
            .font(.caption)
            .foregroundColor(.gray)
    }
}

private func actionSection() -> some View {
    HStack(spacing: 12) {
        Button("Follow") {
            // action
        }
        .buttonStyle(.borderedProminent)
        
        Button("Message") {
            // action
        }
        .buttonStyle(.bordered)
    }
}

final class MockProfileViewModel: ProfileViewModel {
    
    override init() {
        super.init()
        
        self.profile = UserProfile(
            id: "1",
            name: "Preview User",
            username: "@preview",
            bio: "This is SwiftUI Preview 🚀",
            avatarURL: "https://i.pravatar.cc/300",
            followers: 999,
            following: 123,
            posts: 42,
            status: true
        )
        
        self.isLoading = false
    }
    
    override func fetchProfile() async {
        // do nothing
    }
}

import CoreLocation
import Combine

struct UserLocation: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let lastUpdated: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}


final class LocationManager: NSObject, ObservableObject {
    
    private let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func start() {
        manager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last?.coordinate
    }
}

import Foundation

protocol SocketClientProtocol {
    func connect()
    func disconnect()
    func sendLocation(_ location: UserLocation)
    var onReceive: (([UserLocation]) -> Void)? { get set }
}

//final class WebSocketClient: SocketClientProtocol {
//    
//    private var task: URLSessionWebSocketTask?
//    var onReceive: (([UserLocation]) -> Void)?
//    
//    func connect() {
//        let url = URL(string: "wss://your-server.com/socket")!
//        task = URLSession.shared.webSocketTask(with: url)
//        task?.resume()
//        listen()
//    }
//    
//    func disconnect() {
//        task?.cancel(with: .goingAway, reason: nil)
//    }
//    
//    func sendLocation(_ location: UserLocation) {
//        let data = try! JSONEncoder().encode(location)
//        let message = URLSessionWebSocketTask.Message.data(data)
//        task?.send(message) { error in
//            if let error = error {
//                print("Send error:", error)
//            }
//        }
//    }
//    
//    private func listen() {
//        task?.receive { [weak self] result in
//            switch result {
//            case .success(let message):
//                if case let .data(data) = message {
//                    let users = try? JSONDecoder().decode([UserLocation].self, from: data)
//                    self?.onReceive?(users ?? [])
//                }
//            case .failure(let error):
//                print("Receive error:", error)
//            }
//            self?.listen()
//        }
//    }
//}

final class MockSocketClient: SocketClientProtocol {
    
    var onReceive: (([UserLocation]) -> Void)?
    private var timer: Timer?
    
    func connect() {
        startMock()
    }
    
    func disconnect() {
        timer?.invalidate()
    }
    
    func sendLocation(_ location: UserLocation) {
        // mock ไม่ต้องทำอะไร
    }
    
    private func startMock() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            
            let users = Self.generateMockUsers()
            self?.onReceive?(users)
        }
    }
    
    private static func generateMockUsers() -> [UserLocation] {
        let baseLat = 13.6
        let baseLng = 100.7
        
        return (0..<10).map { i in
            let lat = baseLat + Double.random(in: -0.01...0.01)
            let lng = baseLng + Double.random(in: -0.01...0.01)
            
            return UserLocation(
                id: "\(i)",
                name: "User \(i)",
                latitude: lat,          // ✅ แก้ตรงนี้
                longitude: lng,         // ✅ แก้ตรงนี้
                lastUpdated: Date()
            )
        }
    }
}

import Combine

protocol LocationRepositoryProtocoll {
    func connect()
    func send(location: UserLocation)
    var usersPublisher: AnyPublisher<[UserLocation], Never> { get }
}

final class LocationRepositoryy: LocationRepositoryProtocoll {
    
    private var socket: SocketClientProtocol
    private let subject = PassthroughSubject<[UserLocation], Never>()
    
    var usersPublisher: AnyPublisher<[UserLocation], Never> {
        subject.eraseToAnyPublisher()
    }
    
    init(socket: SocketClientProtocol) {
        self.socket = socket
        
        self.socket.onReceive = { [weak self] users in
            self?.subject.send(users)
        }
    }
    
    func connect() {
        socket.connect()
    }
    
    func send(location: UserLocation) {
        socket.sendLocation(location)
    }
}

import Combine
import MapKit

@MainActor
final class MapViewModell: ObservableObject {
    
    @Published var users: [UserLocation] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.6, longitude: 100.7),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private let locationManager: LocationManager
    private let repo: LocationRepositoryProtocoll
    private var cancellables = Set<AnyCancellable>()
    
    init(locationManager: LocationManager,
         repo: LocationRepositoryProtocoll) {
        self.locationManager = locationManager
        self.repo = repo
        
        bind()
    }
    
    private func bind() {
        repo.usersPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$users)
        
        locationManager.$location
            .compactMap { $0 }
            .sink { [weak self] coordinate in
                guard let self = self else { return }
                
                let me = UserLocation(
                    id: "me",
                    name: "Me",
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    lastUpdated: Date()
                )
                
                self.repo.send(location: me)
                self.region.center = coordinate
            }
            .store(in: &cancellables)
    }
    
    func onAppear() {
        locationManager.requestPermission()
        locationManager.start()
        repo.connect()
    }
}

import SwiftUI
import MapKit

struct MarauderMapView: View {
    
    @StateObject private var vm: MapViewModell
    
    init() {
        let locationManager = LocationManager()
        let socket = MockSocketClient()
        let repo = LocationRepositoryy(socket: socket)
        
        _vm = StateObject(
            wrappedValue: MapViewModell(
                locationManager: locationManager,
                repo: repo
            )
        )
    }
    
    var body: some View {
        Map(coordinateRegion: $vm.region,
            annotationItems: vm.users) { user in
            
            MapAnnotation(coordinate: user.coordinate) {
                UserAnnotationView(user: user)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            vm.onAppear()
        }
    }
}

struct UserAnnotationView: View {
    
    let user: UserLocation
    
    var body: some View {
        VStack(spacing: 4) {
            Text(user.name)
                .font(.caption)
                .padding(6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            
            Circle()
                .fill(Color.blue)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
        }
    }
}
