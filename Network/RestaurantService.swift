//
//  RestaurantService.swift
//  KleagueApp
//
//  Created by 최영건 on 6/3/25.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NMapsMap
import CoreLocation

struct Restaurant: Decodable {
    let title: String
    let mapx: Double
    let mapy: Double

    var name: String {
        title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
    }

    var longitude: Double {
        return Double(mapx) * 0.00001
    }

    var latitude: Double {
        return Double(mapy) * 0.00001
    }
}

struct RestaurantResponse: Decodable {
    let items: [Restaurant]
}

class RestaurantService {
    
    func fetchRestaurants(keyword: String) -> Single<[Restaurant]> {
        return Single.create { single in
            guard let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://openapi.naver.com/v1/search/local.json?query=\(query)&display=5&start=1&sort=comment") else {
                single(.failure(NSError(domain: "Invalid URL", code: 400)))
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Zm6giPTaxE0mq9ly3Asw", forHTTPHeaderField: "X-Naver-Client-Id")
            request.addValue("2Qoz73LSkJ", forHTTPHeaderField: "X-Naver-Client-Secret")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard response is HTTPURLResponse else {
                    single(.failure(NSError(domain: "Invalid Response", code: 500)))
                    return
                }
                
                guard let data = data else {
                    single(.failure(NSError(domain: "No data", code: 500)))
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(RestaurantResponse.self, from: data)
                    single(.success(decoded.items))
                } catch {
                    single(.failure(error))
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
