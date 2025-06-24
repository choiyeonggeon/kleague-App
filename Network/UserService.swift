//
//  UserService.swift
//  KleagueApp
//
//  Created by 최영건 on 6/24/25.
//

import FirebaseAuth
import FirebaseFirestore

class UserService {
    static let shared = UserService()
    
    private init() {}
    
    func checkIfAdmin(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let docRef = Firestore.firestore().collection("users").document(uid)
            docRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let role = data["role"] as? String {
                completion(role == "admin")
            } else {
                completion(false)
            }
        }
    }
}
