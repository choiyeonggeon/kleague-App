////
////  NaverPlaceSearchService.swift
////  KleagueApp
////
////  Created by 최영건 on 6/3/25.
////
//
//import Foundation
//import RxSwift
//
//class KakaoPlaceSearchService {
//    
//    private let apiKey = "d9XauxZtIs1q5zXGYGVDAtesRsZbdoMq"
//    
//    func search(keyword: String) -> Single<[Restaurant]> {
//        return Single.create { single in
//            guard let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//                  let url = URL(string: "https://dapi.kakao.com/v2/local/search/keyword.json?query=\(query)&category_group_code=FD6") else {
//                single(.failure(NSError(domain: "Invalid URL", code: 0)))
//                return Disposables.create()
//            }
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.addValue("KakaoAK \(self.apiKey)", forHTTPHeaderField: "Authorization")
//            request.addValue(Bundle.main.bundleIdentifier ?? "com.cyg050217.112399", forHTTPHeaderField: "KA-APP")
//            request.addValue("https://mykleagueapp.com", forHTTPHeaderField: "KA-ORIGIN")
//            request.addValue("ios", forHTTPHeaderField: "KA-OS")
//
//            
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    single(.failure(error))
//                    return
//                }
//                
//                guard let data = data else {
//                    single(.failure(NSError(domain: "No Data", code: 0)))
//                    return
//                }
//
//                // 👉 디버깅용 로그
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("📦 카카오 응답: \(jsonString)")
//                }
//
//                do {
//                    let decoded = try JSONDecoder().decode(KakaoPlaceResponse.self, from: data)
//                    single(.success(decoded.documents))
//                } catch {
//                    print("❌ 디코딩 실패: \(error)")
//                    single(.failure(error))
//                }
//            }
//            task.resume()
//            
//            return Disposables.create {
//                task.cancel()
//            }
//        }
//    }
//}
