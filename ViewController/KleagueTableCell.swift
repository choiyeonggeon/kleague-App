//
//  KleagueTableCell.swift
//  KleagueApp
//
//  Created by 최영건 on 5/30/25.
//

// KleagueTableCell.swift

import UIKit
import SnapKit
import Kingfisher // 이미지 로딩을 위해 사용 추천

class KleagueTableCell: UITableViewCell {
    
    private let logoImageView = UIImageView()
    private let nameLabel = UILabel()
    private let pointsLabel = UILabel()
    private let recordLabel = UILabel()
    private let rankLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [rankLabel, logoImageView, nameLabel, pointsLabel, recordLabel].forEach {
            contentView.addSubview($0)
            contentView.backgroundColor = .systemGray6
        }

        rankLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.font = .systemFont(ofSize: 16)
        pointsLabel.font = .systemFont(ofSize: 14)
        recordLabel.font = .systemFont(ofSize: 12)
        recordLabel.textColor = .gray
        logoImageView.contentMode = .scaleAspectFit

        rankLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(8)
            $0.width.equalTo(24)
        }

        logoImageView.snp.makeConstraints {
            $0.leading.equalTo(rankLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(32)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(logoImageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview().offset(-10)
        }

        pointsLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
        }

        recordLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(with team: TeamStanding) {
        rankLabel.text = "\(team.rank)"
        nameLabel.text = team.team.name
        pointsLabel.text = "승점: \(team.points)"
        recordLabel.text = "경기: \(team.all.played), 골득실: \(team.goalsDiff)"
        logoImageView.kf.setImage(with: URL(string: team.team.logo))
    }
}
