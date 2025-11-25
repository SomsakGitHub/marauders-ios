import SwiftUI
import MapKit
import CoreLocation
import Combine

class AnimatedPerson: ObservableObject, Identifiable {
    let id = UUID()
    @Published var coordinate: CLLocationCoordinate2D
    @Published var trail: [MapPoint] = []

    init(coord: CLLocationCoordinate2D) {
        self.coordinate = coord
    }

    func move(to new: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 1.0)) {
            coordinate = new
            trail.append(MapPoint(coordinate: new))
        }
    }
}


class FriendSimulator: ObservableObject {
    @Published var friends: [AnimatedPerson] = []

    init() {
        friends = [
            AnimatedPerson(coord: CLLocationCoordinate2D(latitude: 13.757, longitude: 100.502)),
            AnimatedPerson(coord: CLLocationCoordinate2D(latitude: 13.755, longitude: 100.503))
        ]

        simulateMovement()
    }

    // Random walk every 3 seconds
    func simulateMovement() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            for friend in self.friends {
                let latDelta = Double.random(in: -0.0005...0.0005)
                let lonDelta = Double.random(in: -0.0005...0.0005)

                let new = CLLocationCoordinate2D(
                    latitude: friend.coordinate.latitude + latDelta,
                    longitude: friend.coordinate.longitude + lonDelta
                )

                friend.move(to: new)
            }
        }
    }
}


struct WalkingDot: View {
    @State private var bounce = false
    var color: Color
    var size: CGFloat = 18

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(color.opacity(0.6), lineWidth: 4)
                    .scaleEffect(bounce ? 1.6 : 1.0)
                    .opacity(bounce ? 0.3 : 0.7)
            )
            .scaleEffect(bounce ? 1.1 : 1.0)
            .shadow(color: color.opacity(0.8), radius: bounce ? 8 : 3)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                    bounce.toggle()
                }
            }
    }
}


extension AnimatedPerson {
    func fadeOldTrail() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            if self.trail.count > 2 {
                self.trail.removeFirst()
            }
            self.fadeOldTrail()
        }
    }
}


struct MapPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}


struct MarauderMapView: View {
    @ObservedObject var locationManager: LocationManager
    var friends: [MapPoint]   // ← เพิ่มตรงนี้

    @StateObject var user = AnimatedPerson(
        coord: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018)
    )

    var body: some View {
        Map {
            // User trail
            ForEach(user.trail) { point in
                Annotation("", coordinate: point.coordinate) {
                    Circle()
                        .fill(.green.opacity(0.7))
                        .frame(width: 6, height: 6)
                }
            }
            
            // Friend dots
            ForEach(friends) { f in
                Annotation("", coordinate: f.coordinate) {
                    WalkingDot(color: .orange, size: 22)
                }
            }
        }
        .onReceive(locationManager.$userLocation) { loc in
            if let loc = loc {
                user.move(to: loc.coordinate)
            }
        }
    }
}


