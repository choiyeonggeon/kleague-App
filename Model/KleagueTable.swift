////
////  KleagueTeam.swift
////  KleagueApp
////
////  Created by 최영건 on 5/31/25.
////
//
//import Foundation
//
//struct KleagueTableResponse: Codable {
//    let table: [KleagueTeam]?
//}
//
//struct KleagueTeam: Codable {
//    let name: String          // 팀 이름
//    let teamid: String        // 팀 ID
//    let played: String        // 경기 수
//    let goalsfor: String      // 득점
//    let goalsagainst: String  // 실점
//    let goaldifference: String // 골득실
//    let win: String
//    let draw: String
//    let loss: String
//    let total: String         // 승점
//
//    enum CodingKeys: String, CodingKey {
//        case name = "strTeam"
//        case teamid = "idTeam"
//        case played = "intPlayed"
//        case goalsfor = "intGoalsFor"
//        case goalsagainst = "intGoalsAgainst"
//        case goaldifference = "intGoalDifference"
//        case win = "intWin"
//        case draw = "intDraw"
//        case loss = "intLoss"
//        case total = "intPoints"
//    }
//}
