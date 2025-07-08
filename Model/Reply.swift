//
//  Reply.swift
//  KleagueApp
//
//  Created by 최영건 on 7/8/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct Reply {
    let id: String
    let parentCommentId: String
    let text: String
    let author: String
    let authorUid: String
    let createdAt: Date
    
    init?(from document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        guard
            let text = data["text"] as? String,
            let author = data["author"] as? String,
            let authorUid = data["authorUid"] as? String,
            let timestamp = data["createdAt"] as? Timestamp
        else { return nil }
        
        self.id = document.documentID
        self.parentCommentId = data["parentCommentId"] as? String ?? ""
        self.text = text
        self.author = author
        self.authorUid = authorUid
        self.createdAt = timestamp.dateValue()
    }
}
