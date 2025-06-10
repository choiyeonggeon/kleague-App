//
//  NaverPlaceSearchService.swift
//  KleagueApp
//
//  Created by 최영건 on 6/3/25.
//

import Foundation
import RxSwift
import RxCocoa
import NMapsMap
import CoreLocation

struct PlaceSearch: Decodable {
    let title: String
    let address: String
    let mapx: Double
    let mapy: Double

    private enum CodingKeys: String, CodingKey {
        case title, address, mapx, mapy
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        address = try container.decode(String.self, forKey: .address)
        

        let mapxString = try container.decode(String.self, forKey: .mapx)
        let mapyString = try container.decode(String.self, forKey: .mapy)

        guard let mapx = Double(mapxString), let mapy = Double(mapyString) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.mapx, CodingKeys.mapy], debugDescription: "좌표값이 잘못되었습니다."))
        }

        self.mapx = mapx
        self.mapy = mapy
    }
}

struct PlaceSearchResponse: Decodable {
    let items: [PlaceSearch]
}

class NaverPlaceSearchService {
    private let clientId = "Zm6giPTaxE0mq9ly3Asw"
    private let clientSecret = "2Qoz73LSkJ"
    
    func search(keyword: String) -> Observable<[PlaceSearch]> {
        return Observable.create { observable in
            guard let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: "https://openapi.naver.com/v1/search/local.json?query=\(query)&display=5&start=1&sort=comment") else {
                observable.onNext([])
                observable.onCompleted()
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(self.clientId, forHTTPHeaderField: "X-Naver-Client-Id")
            request.addValue(self.clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    observable.onError(error)
                    return
                }
                
                guard let data = data else {
                    observable.onNext([])
                    observable.onCompleted()
                    return
                }
                
                if let error = error {
                 print("🚨 네트워크 에러: \(error)")
                 observable.onError(error)
                 return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                 print("🔎 네이버 검색 응답:\n\(jsonString)")
                }
                
                do {
                    let decoded = try JSONDecoder().decode(PlaceSearchResponse.self, from: data)
                    observable.onNext(decoded.items)
                    observable.onCompleted()
                } catch {
                    print("디코딩 실패: \(error.localizedDescription)")
                    observable.onError(error)
                }
            }
            
            task.resume()
            
            return Disposables.create() {
                task.cancel()
            }
            
        }
        
    }
}
