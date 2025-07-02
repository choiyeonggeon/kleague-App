//
//  Post.swift
//  KleagueApp
//

import Foundation
import FirebaseFirestore

struct Post {
    var firstReportedAt: Date?
    var id: String
    var title: String
    var content: String
    var preview: String
    var likes: Int
    var dislikes: Int
    let commentsCount: Int
    let team: String
    let author: String
    let authorUid: String
    let showReportAlert: Bool
    let createdAt: Date
    let reportCount: Int
    var email: String?
    var isHidden: Bool
    
    init?(from document: DocumentSnapshot) {
        self.id = document.documentID
        let data = document.data() ?? [:]
        
        guard
            let title = data["title"] as? String,
            let content = data["content"] as? String,
            let team = data["team"] as? String,
            let author = data["author"] as? String,
            let authorUid = data["authorUid"] as? String,
            let timestamp = data["createdAt"] as? Timestamp
        else {
            print("❌ Post 초기화 실패: 필수 필드 없음 또는 타입 불일치")
            return nil
        }
        
        self.title = title
        self.content = content
        self.preview = String(content.prefix(50))
        self.team = team
        self.author = author
        self.authorUid = authorUid
        self.createdAt = timestamp.dateValue()
        
        self.likes = data["likes"] as? Int ?? 0
        self.dislikes = data["dislikes"] as? Int ?? 0
        self.commentsCount = data["commentsCount"] as? Int ?? 0
        self.isHidden = data["isHidden"] as? Bool ?? false
        self.firstReportedAt = (data["firstReportedAt"] as? Timestamp)?.dateValue()
        self.showReportAlert = data["showReportAlert"] as? Bool ?? false
        self.reportCount = data["reportCount"] as? Int ?? 0
        self.email = data["email"] as? String
    }
}
