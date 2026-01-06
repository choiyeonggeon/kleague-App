//
//  AdminSuspendedUserVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Foundation

class AdminSuspendedUserVC: UIViewController {
    private var suspendedUsers: [QueryDocumentSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchSuspendedUsers { [weak self] users in
            self?.suspendedUsers = users
        }
    }
    
    func fetchSuspendedUsers(completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("isSuspended", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("🔥 활동 정지 유저 불러오기 실패: \(error.localizedDescription)")
                    completion([])
                } else {
                    completion(snapshot?.documents ?? [])
                }
            }
    }
}
