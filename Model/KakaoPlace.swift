////
////  KakaoPlace.swift
////  KleagueApp
////
////  Created by 최영건 on 6/23/25.
////
//
//import Foundation
//import CoreLocation
//
//struct KakaoPlace: Decodable {
//    let place_name: String
//    let x: String
//    let y: String
//    
//    var name: String { place_name }
//    
//    var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(
//            latitude: Double(y) ?? 0.0,
//            longitude: Double(x) ?? 0.0
//        )
//    }
//}
