//
//  ChatMessage.swift
//  KleagueApp
//
//  Created by 최영건 on 8/20/25.
//

import Foundation
import FirebaseFirestore

struct ChatMessage {
    let id: String
    let text: String
    let senderId: String
    let createdAt: Date
    
    static func fromDict(data: [String: Any], id: String) -> ChatMessage? {
        guard let text = data["text"] as? String,
              let senderId = data["senderId"] as? String,
              let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
            return nil
        }
        return ChatMessage(id: id, text: text, senderId: senderId, createdAt: createdAt)
    }
}
