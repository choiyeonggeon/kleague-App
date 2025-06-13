//
//  RestaurantService.swift
//  KleagueApp
//
//  Created by 최영건 on 6/3/25.
//

import Foundation
import RxSwift
import CoreLocation

struct Restaurant: Decodable {
    let title: String
    let mapx: String  // 원본 String
    let mapy: String
    
    var name: String {
        title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
    }
    
    var coordinate: CLLocationCoordinate2D {
        // TM128 좌표를 WGS84 위경도로 변환
        let x = Double(mapx) ?? 0
        let y = Double(mapy) ?? 0
        return RestaurantService.convertTM128ToWGS84(x: x, y: y)
    }
    
    var latitude: Double { coordinate.latitude }
    var longitude: Double { coordinate.longitude }
    
    private enum CodingKeys: String, CodingKey {
        case title, mapx, mapy
    }
}

struct RestaurantResponse: Decodable {
    let items: [Restaurant]
}

class RestaurantService {
    
    private let clientId = "Zm6giPTaxE0mq9ly3Asw"
    private let clientSecret = "2Qoz73LSkJ"
    
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
            request.addValue(self.clientId, forHTTPHeaderField: "X-Naver-Client-Id") // 변경 필요
            request.addValue(self.clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret") // 변경 필요
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    single(.failure(NSError(domain: "Invalid Response", code: 500)))
                    return
                }
                
                guard let data = data else {
                    single(.failure(NSError(domain: "No Data", code: 500)))
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
            
            return Disposables.create { task.cancel() }
        }
    }
    
    // TM128 좌표계 → WGS84 위경도 변환 공식
    static func convertTM128ToWGS84(x: Double, y: Double) -> CLLocationCoordinate2D {
        let RE: Double = 6371.00877 // 지구 반경(km)
        let GRID: Double = 5.0 // 격자 간격(km)
        let SLAT1: Double = 30.0 // 투영 위도1(degree)
        let SLAT2: Double = 60.0 // 투영 위도2(degree)
        let OLON: Double = 126.0 // 기준점 경도(degree)
        let OLAT: Double = 38.0 // 기준점 위도(degree)
        let XO: Double = 43 // 기준점 X좌표(GRID)
        let YO: Double = 136 // 기준점 Y좌표(GRID)
        
        let DEGRAD = Double.pi / 180.0
        let RADDEG = 180.0 / Double.pi
        
        let re = RE / GRID
        let slat1 = SLAT1 * DEGRAD
        let slat2 = SLAT2 * DEGRAD
        let olon = OLON * DEGRAD
        let olat = OLAT * DEGRAD
        
        var sn = tan(Double.pi * 0.25 + slat2 * 0.5) / tan(Double.pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn)
        var sf = tan(Double.pi * 0.25 + slat1 * 0.5)
        sf = pow(sf, sn) * cos(slat1) / sn
        var ro = tan(Double.pi * 0.25 + olat * 0.5)
        ro = re * sf / pow(ro, sn)
        
        let xn = x - XO
        let yn = ro - y + YO
        let ra = sqrt(xn * xn + yn * yn)
        var alat = pow((re * sf / ra), (1.0 / sn))
        alat = 2.0 * atan(alat) - Double.pi * 0.5
        
        var theta = 0.0
        if abs(xn) <= 0.0 {
            theta = 0.0
        } else {
            if abs(yn) <= 0.0 {
                theta = Double.pi * 0.5
                if xn < 0.0 {
                    theta = -theta
                }
            } else {
                theta = atan2(xn, yn)
            }
        }
        
        let alon = theta / sn + olon
        
        return CLLocationCoordinate2D(latitude: alat * RADDEG, longitude: alon * RADDEG)
    }
}
