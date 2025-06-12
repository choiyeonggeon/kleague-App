//
//  APIService.swift
//  KleagueApp
//
//  Created by 최영건 on 5/30/25.
//

import Foundation
import RxSwift

class APIService {
    static let shared = APIService()
    private let apiKey = "51bb3fe3a2mshc34815e1d4aac36p1d7f58jsn848763975749"
    
    private init() {}
    
    func fetchKleagueStandings(for leagueID: Int, season: Int = 2025) -> Observable<[TeamStanding]> {
        guard let url = URL(string: "https://api-football-v1.p.rapidapi.com/v3/standings?league=\(leagueID)&season=\(season)") else {
            return .error(NSError(domain: "Invalid URL", code: -1))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")  // RapidAPI 키만
        request.setValue("api-football-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        return URLSession.shared.rx.data(request: request)
            .do(onNext: { data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 받은 JSON: \(jsonString)")
                }
            })
            .map { data in
                let decoded = try JSONDecoder().decode(StandingsResponse.self, from: data)
                return decoded.response.first?.league.standings.first ?? []
            }
            .catchAndReturn([])
    }
    
    func fetchKleagueMatches(leagueID: Int, season: Int = 2025) -> Observable<[Match]> {
        guard let url = URL(string: "https://api-football-v1.p.rapidapi.com/v3/fixtures?league=\(leagueID)&season=\(season)") else {
            return .error(NSError(domain: "Invalid URL", code: -1))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("api-football-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")

        return URLSession.shared.rx.data(request: request)
            .map { data in
                let decoded = try JSONDecoder().decode(MatchResponse.self, from: data)
                return decoded.response
            }
    }
}
