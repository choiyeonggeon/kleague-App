//
//  APIService.swift
//  KleagueApp
//
//  Created by 최영건 on 5/30/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func fetchKleagueTableData(for leagueID: Int) -> Observable<[KleagueTeam]> {
        let urlString = "https://www.thesportsdb.com/api/v1/json/123/lookuptable.php?l=\(leagueID)"
        
        guard let url = URL(string: urlString) else {
            return .error(NSError(domain: "Invalid URL", code: -1))
        }
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data in
                let decoded = try JSONDecoder().decode(KleagueTableResponse.self, from: data)
                return decoded.table ?? []
            }
            .catchAndReturn([])
    }
    
}
