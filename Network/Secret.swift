////
////  Secret.swift
////  KleagueApp
////
////  Created by 최영건 on 7/15/25.
////
//
//import Foundation
//import NMapsMap
//import NMapsGeometry
//
//enum Secret {
//    static var naverClientId: String {
//        guard let value = ProcessInfo.processInfo.environment["NMF_CLIENT_ID"] else {
//            fatalError("NMF_CLIENT_ID 누락 (Secret.xcconfig 확인)")
//        }
//        return value
//    }
//    
//    static var naverClientSecret: String {
//        guard let value = ProcessInfo.processInfo.environment["NAVER_CLIENT_SECRET"] else {
//            fatalError("NEVER_CLIENT_SECRET 누락 (Secret.xcconfig 확인)")
//        }
//        return value
//    }
//}
