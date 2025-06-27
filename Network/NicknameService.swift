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
                completion(false)  // 에러 나면 사용 불가로 처리
                return
            }
            
            if let data = result?.data as? [String: Bool],
               let isDuplicate = data["duplicate"] {
                completion(!isDuplicate)  // 중복이면 false, 아니면 true 반환
            } else {
                completion(false)  // 결과가 이상하면 사용 불가 처리
            }
        }
    }

}

