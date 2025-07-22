////
////  NaverPlaceSearchService.swift
////  KleagueApp
////
////  Created by 최영건 on 6/3/25.
////
//
//import Foundation
//import RxSwift
//import NMapsMap
//import NMapsGeometry
//
//class NaverPlaceSearchService {
//    func search(keyword: String) -> Observable<[PlaceSearch]> {
//        return Observable.create { observer in
//            guard let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//                  let url = URL(string: "https://openapi.naver.com/v1/search/local.json?query=\(query)&display=20&start=1&sort=comment") else {
//                observer.onNext([])
//                observer.onCompleted()
//                return Disposables.create()
//            }
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "GET"
//            request.addValue(Secret.naverClientId, forHTTPHeaderField: "X-Naver-Client-Id")
//            request.addValue(Secret.naverClientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
//            
//            let task = URLSession.shared.dataTask(with: request) { data, _, error in
//                if let error = error {
//                    observer.onError(error)
//                    return
//                }
//                
//                guard let data = data else {
//                    observer.onNext([])
//                    observer.onCompleted()
//                    return
//                }
//                
//                do {
//                    let response = try JSONDecoder().decode(PlaceSearchResponse.self, from: data)
//                    observer.onNext(response.items)
//                    observer.onCompleted()
//                } catch {
//                    observer.onError(error)
//                }
//            }
//            
//            task.resume()
//            return Disposables.create { task.cancel() }
//        }
//    }
//}
