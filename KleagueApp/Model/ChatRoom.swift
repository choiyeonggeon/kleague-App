//
//  ChatRoom.swift
//  KleagueApp
//
//  Created by 최영건 on 9/8/25.
//

import Foundation
import FirebaseFirestore

struct ChatRoom: Codable {
    let id: String
    let title: String
    let participants: [String]
    let lastMessage: String?
    let lastUpdatedAt: Date?
    var otherUserNickname: String?
    var productImageUrl: String?
//    let productId: String
}
