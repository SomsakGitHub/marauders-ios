//
//  FeedModel.swift
//  marauderS
//
//  Created by somsak on 5/5/2568 BE.
//

import Foundation
import CoreLocation

struct Post: Identifiable, Codable {
    let id: String
    let videoUrl: URL
    let latitude: Double
    let longitude: Double
//    
//    var location: CLLocation {
//        CLLocation(latitude: latitude, longitude: longitude)
//    }
}
