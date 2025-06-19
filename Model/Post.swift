//
//  Post.swift
//  gugchugyeojido
//
//  Created by 최영건 on 6/16/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct Post: Codable {
    let id: String
    let title: String
    let content: String
    let preview: String
    var likes: Int
    var dislikes: Int
    let commentsCount: Int
    let team: String
    let author: String
    let createdAt: Date

    init?(from document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        
        guard let title = data["title"] as? String,
              let content = data["content"] as? String,
              let likes = data["likes"] as? Int,
              let dislikes = data["dislikes"] as? Int,
              let commentsCount = data["commentsCount"] as? Int,
              let team = data["teamName"] as? String,
              let author = data["author"] as? String,
              let timestamp = data["createdAt"] as? Timestamp else {
            return nil
        }

        self.id = document.documentID
        self.title = title
        self.content = content
        self.preview = String(content.prefix(50))
        self.likes = likes
        self.dislikes = dislikes
        self.commentsCount = commentsCount
        self.team = team
        self.author = author
        self.authorUid = authorUid
        self.createdAt = timestamp.dateValue()
    }
}

extension Date {
    var timeAgoDisplay: String {
        let secondsAgo = Int(Date().timeIntervalSince(self))

        if secondsAgo < 60 {
            return "방금 전"
        } else if secondsAgo < 3600 {
            return "\(secondsAgo / 60)분 전"
        } else if secondsAgo < 86400 {
            return "\(secondsAgo / 3600)시간 전"
        } else if secondsAgo < 604800 {
            return "\(secondsAgo / 86400)일 전"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: self)
        }
    }
}
