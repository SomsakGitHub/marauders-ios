import Foundation
import CoreLocation

class FeedViewModel: ObservableObject {
    @Published var posts = [Post]()
//    @Published var data: DataType?
    
    let videoUrls = [
        Bundle.main.url(forResource: "oneDancing", withExtension: "mp4")!,
        Bundle.main.url(forResource: "fireworks", withExtension: "mp4")!,
        Bundle.main.url(forResource: "selfie", withExtension: "mp4")!,
        Bundle.main.url(forResource: "threeDancing", withExtension: "mp4")!,
//        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
//        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
//        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
//        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"
    ]
    
    init () {
        fetchPosts()
    }
    
    func fetchPosts() {
        self.posts = [
            .init(id: NSUUID().uuidString, videoUrl: videoUrls[0], latitude: 13.71646928950651, longitude: 100.52907189548483),
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
    
//    func fetchData() async {
//        do {
//            let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let decodedData = try JSONDecoder().decode(DataType.self, from: data)
//            DispatchQueue.main.async {
//                self.data = decodedData
//            }
//        } catch {
//            print("Error fetching data: \(error)")
//        }
//    }
}

struct DataType: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
