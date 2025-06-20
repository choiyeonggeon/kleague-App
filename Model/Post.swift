//
//  Post.swift
//  KleagueApp
//

import Foundation
import FirebaseFirestore

struct Post {
    let id: String
    let title: String
    let content: String
    let preview: String
    var likes: Int
    var dislikes: Int
    let commentsCount: Int
    let team: String
    let author: String
    let authorUid: String
    let showReportAlert: Bool
    let createdAt: Date

    init?(from document: DocumentSnapshot) {
        self.id = document.documentID

        let data = document.data() ?? [:]

        guard
            let title = data["title"] as? String,
            let content = data["content"] as? String,
            let likes = data["likes"] as? Int,
            let dislikes = data["dislikes"] as? Int,
            let commentsCount = data["commentsCount"] as? Int,
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
        self.likes = likes
        self.dislikes = dislikes
        self.commentsCount = commentsCount
        self.team = team
        self.author = author
        self.authorUid = authorUid
        self.createdAt = timestamp.dateValue()

        // showReportAlert은 없어도 false로 처리
        self.showReportAlert = data["showReportAlert"] as? Bool ?? false
    }

}
