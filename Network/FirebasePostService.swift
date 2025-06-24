//
//  FirebasePostService.swift
//  KleagueApp
//
//  Created by 최영건 on 6/24/25.
//

import Foundation
import FirebaseFirestore

class FirebasePostService {
    
    static let shared = FirebasePostService()
    
    private init() {}
    
    func updatePost(postID: String, newTitle: String, newContent: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let docRef = Firestore.firestore().collection("posts").document(postID)
        let preview = String(newContent.prefix(50))
        
        docRef.updateData([
            "title": newTitle,
            "content": newContent,
            "preview": preview,
            "updatedAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deletePost(postID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let docRef = Firestore.firestore().collection("posts").document(postID)
        
        docRef.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchReportedPosts(completion: @escaping ([Post]) -> Void) {
        Firestore.firestore().collection("posts")
            .whereField("reportCount", isEqualTo: 0)
            .order(by: "reportCount", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let posts = documents.compactMap { Post(from: $0) }
                completion(posts)
        }
    }
}
