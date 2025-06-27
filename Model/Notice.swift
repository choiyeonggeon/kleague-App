//
//  Notice.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import Foundation
import FirebaseFirestore

struct Notice {
    let id: String
    let title: String
    let content: String
    let date: Date
    let isPinned: Bool

    init?(from document: DocumentSnapshot) {
        let data = document.data() ?? [:]

        guard
            let title = data["title"] as? String,
            let content = data["content"] as? String,
            let date = data["date"] as? Timestamp,
            let isPinned = data["isPinned"] as? Bool
        else {
            return nil
        }

        self.id = document.documentID
        self.title = title
        self.content = content
        self.date = date.dateValue()
        self.isPinned = isPinned
    }
}
