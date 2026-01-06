//
//  PlaceSearch.swift
//  KleagueApp
//
//  Created by 최영건 on 7/15/25.
//

import Foundation

struct PlaceSearch: Decodable, Equatable {
    let title: String
    let address: String
    let telephone: String?
    let category: String
    
    var cleanTitle: String {
        title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "<b>", with: "")
    }
    
    var id: String {
        return "\(cleanTitle)-\(address)"
    }
}
