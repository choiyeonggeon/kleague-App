//
//  KleagueTableCell.swift
//  KleagueApp
//
//  Created by 최영건 on 5/30/25.
//

import UIKit
import RxSwift
import RxCocoa

class KleagueTableCell: UITableViewCell {
    
    func configure(with team: KleagueTeam, rank: Int) {
        textLabel?.text = "\(rank). \(team.name) - 승점 \(team.total)"
        detailTextLabel?.text = "승: \(team.win), 무: \(team.draw), 패: \(team.loss)"
    }
}
