//
//  Post.swift
//  gugchugyeojido
//
//  Created by 최영건 on 6/16/25.
//

import Foundation

struct Post {
    let title: String
    let preview: String
    let likes: Int
    let comments: Int
    let team: String
    let author: String

    init?(from data: [String: Any]) {
        guard let title = data["title"] as? String,
              let preview = data["content"] as? String,
              let likes = data["likes"] as? Int,
              let comments = data["commentsCount"] as? Int,
              let team = data["teamName"] as? String,
              let author = data["author"] as? String else {
            return nil
        }
        self.title = title
        self.preview = preview
        self.likes = likes
        self.comments = comments
        self.team = team
        self.author = author
    }
}
