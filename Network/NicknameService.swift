//
//  NicknameService.swift
//  KleagueApp
//
//  Created by 최영건 on 6/26/25.
//

import FirebaseFunctions

class NicknameService {
    lazy var functions = Functions.functions()
    
    func checkNickname(_ nickname: String, completion: @escaping (Bool) -> Void) {
        functions.httpsCallable("checkNickname").call(["nickname": nickname]) { result, error in
            if let error = error {
                print("에러: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let data = result?.data as? [String: Bool],
               let isDuplicate = data["duplicate"] {
                completion(!isDuplicate)
            } else {
                completion(false)
            }
        }
    }
    
}

