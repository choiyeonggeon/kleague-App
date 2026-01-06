//
//  CustomerInquiry.swift
//  KleagueApp
//
//  Created by 최영건 on 6/26/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct CustomerInquiry {
    let id: String
    let authorUid: String
    let title: String
    let content: String
    let createdAt: Date
    let answer: String?
    let answeredAt: Date?
    
    init?(from document: DocumentSnapshot, authorUid: String) {
        let data = document.data() ?? [:]
        
        guard
            let title = data["title"] as? String,
            let content = data["content"] as? String,
            let createdAt = data["createdAt"] as? Timestamp
        else {
            return nil
        }
        
        self.id = document.documentID
        self.authorUid = authorUid
        self.title = title
        self.content = content
        self.createdAt = createdAt.dateValue()
        self.answer = data["answer"] as? String
        self.answeredAt = (data["answeredAt"] as? Timestamp)?.dateValue()
    }
}
