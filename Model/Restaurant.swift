////
////  Restaurant.swift
////  KleagueApp
////
////  Created by 최영건 on 6/13/25.
////
//
//import Foundation
//import CoreLocation
//
//struct Restaurant: Decodable {
//    let place_name: String
//    let x: String
//    let y: String
//    
//    var name: String {
//        return place_name
//    }
//    
//    var latitude: Double {
//        return Double(y) ?? 0.0
//    }
//    
//    var longitude: Double {
//        return Double(x) ?? 0.0
//    }
//    
//    var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    }
//}
