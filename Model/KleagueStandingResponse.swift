//
//  KleagueStandingResponse.swift
//  KleagueApp
//
//  Created by 최영건 on 6/11/25.
//

import Foundation

struct StandingsResponse: Codable {
    let response: [LeagueResponse]
}

struct LeagueResponse: Codable {
    let league: League
}

struct League: Codable {
    let standings: [[TeamStanding]]
}

struct TeamStanding: Codable {
    let rank: Int
    let team: Team
    let points: Int
    let goalsDiff: Int
    let all: AllStats
}

struct Team: Codable {
    let id: Int
    let name: String
    let logo: String
}

struct AllStats: Codable {
    let played: Int
    let win: Int
    let draw: Int
    let lose: Int
}
