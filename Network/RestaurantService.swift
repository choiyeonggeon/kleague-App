////
////  RestaurantService.swift
////  KleagueApp
////
////  Created by 최영건 on 6/3/25.
////
//
//import Foundation
//import RxSwift
//
//struct KakaoPlaceResponse: Decodable {
//    let documents: [Restaurant]
//}
//
//class RestaurantService {
//    
//    private let apiKey: String
//    
//    init() {
//        guard let apiKey = Bundle.main.infoDictionary?["KAKAO_API_KEY"] as? String else {
//            fatalError(#function + ": Missing Kakao API Key")
//        }
//        self.apiKey = apiKey
//    }
//    
//    func fetchRestaurants(keyword: String) -> Single<[Restaurant]> {
//        return Single.create { single in
//            guard let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//                  let url = URL(string: "https://dapi.kakao.com/v2/local/search/keyword.json?query=\(query)&category_group_code=FD6") else {
//                return Disposables.create {
//                    single(.failure(NSError(domain: "Invalid URL", code: 0)))
//                }
//            }
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.addValue(self.apiKey, forHTTPHeaderField: "Authorization")
//            
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    single(.failure(error))
//                    return
//                }
//                guard let data = data else {
//                    single(.failure(NSError(domain: "No Data", code: 0)))
//                    return
//                }
//                
//                // 디버깅
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("📦 Kakao API Response: \(jsonString)")
//                }
//                
//                do {
//                    let decoded = try JSONDecoder().decode(KakaoPlaceResponse.self, from: data)
//                    single(.success(decoded.documents))
//                } catch {
//                    print("❌ JSON Decoding Error: \(error)")
//                    single(.failure(error))
//                }
//            }
//            
//            task.resume()
//            return Disposables.create {
//                task.cancel()
//            }
//        }
//    }
//}
