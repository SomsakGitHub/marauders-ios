import Combine
import CoreLocation

final class FeedViewModel: ObservableObject {
    
    private let service: FeedService
    @Published var posts = [Post]()
//    @Published var data: DataType?
    
    init(service: FeedService) {
        self.service = service
        fetchPosts()
    }
    
    let videoUrls = [
        Bundle.main.url(forResource: "oneDancing", withExtension: "mp4")!,
        Bundle.main.url(forResource: "fireworks", withExtension: "mp4")!,
        Bundle.main.url(forResource: "selfie", withExtension: "mp4")!,
        Bundle.main.url(forResource: "threeDancing", withExtension: "mp4")!,
//        "https://cdn.zerojame.com/oneDancing.mp4",
//        "https://cdn.zerojame.com/fireworks.mp4",
//        "https://cdn.zerojame.com/selfie.mp4",
//        "https://cdn.zerojame.com/threeDancing.mp4"
    ]
    
    func fetchPosts() {
        
        self.posts = [
//            .init(id: NSUUID().uuidString, videoUrl: URL(string: videoUrls[0])! , latitude: 13.71646928950651, longitude: 100.52907189548483),
//            .init(id: NSUUID().uuidString, videoUrl: URL(string: videoUrls[1])!, latitude: 1.0, longitude: 100.0),
//            .init(id: NSUUID().uuidString, videoUrl: URL(string: videoUrls[2])!, latitude: 13.712090225574308, longitude: 100.53229446917453),
//            .init(id: NSUUID().uuidString, videoUrl: URL(string: videoUrls[3])!, latitude: 1.0, longitude: 1.0),
            
                .init(id: NSUUID().uuidString, videoUrl: videoUrls[0] , latitude: 13.71646928950651, longitude: 100.52907189548483),
                .init(id: NSUUID().uuidString, videoUrl: videoUrls[1], latitude: 1.0, longitude: 100.0),
                .init(id: NSUUID().uuidString, videoUrl: videoUrls[2], latitude: 13.712090225574308, longitude: 100.53229446917453),
                .init(id: NSUUID().uuidString, videoUrl: videoUrls[3], latitude: 1.0, longitude: 1.0),
        ]
        
//        let latitude = AppSettings.shared.latitude
//        let longitude = AppSettings.shared.longitude
//        print("latitude", latitude)
//        print("longitude", longitude)
        
//        let radiusInMeters = 1000.0 // 1 กิโลเมตร

//        self.posts = posts.filter { post in
//            let distance = distanceInMeters(
//                lat1: latitude,
//                lon1: longitude,
//                lat2: post.latitude,
//                lon2: post.longitude
//            )
//            return distance <= radiusInMeters
//        }
    }
    
    func distanceInMeters(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let loc1 = CLLocation(latitude: lat1, longitude: lon1)
        let loc2 = CLLocation(latitude: lat2, longitude: lon2)
        return loc1.distance(from: loc2) // คืนค่าเป็นเมตร
    }
    
    
    
    func fetchData() {
        service.login { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    self?.posts = post
                case .failure(let error):
                    print("Error:", error)
                }
            }
            
        }
    }
}

//struct DataType: Codable {
//    let id: Int
//    let userId: Int
//    let title: String
//    let body: String
//}
