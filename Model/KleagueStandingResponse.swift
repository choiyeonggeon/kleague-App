//
//  KleagueStandingResponse.swift
//  KleagueApp
//
//  Created by 최영건 on 6/11/25.
//

import Foundation

// MARK: - Standings

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
    let id: Int?
    let name: String
//    let logo: String
}

struct AllStats: Codable {
    let played: Int
    let win: Int
    let draw: Int
    let lose: Int
}

// MARK: - Matches

struct MatchResponse: Codable {
    let response: [Match]
}

struct Match: Codable {
    let fixture: Fixture
    let teams: Teams
    let goals: Goals
}

struct Fixture: Codable {
    let status: MatchStatus
    let date: String
    let referee: String?
    let venue: Venue?
}

struct MatchStatus: Codable {
    let short: String
    let elapsed: Int?
}

struct Venue: Codable {
    let name: String?
}

struct Teams: Codable {
    let home: Team
    let away: Team
}

struct Goals: Codable {
    let home: Int?
    let away: Int?
}

struct CheeringSong {
    let title: String
    let lyrics: String
    let youtubeURL: String
}

struct TeamCheeringSongs {
    let teamName: String
    let songs: [CheeringSong]
}
