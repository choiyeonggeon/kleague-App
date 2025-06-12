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
    private let koreanTeamNames: [String: String] = [
        "Jeonbuk Motors": "전북",
        "Daegu FC": "대구",
        "Ulsan Hyundai FC": "울산",
        "Daejeon Citizen": "대전",
        "Pohang Steelers": "포항",
        "Gimcheon Sangmu FC": "김천",
        "Gwangju FC": "광주",
        "FC Seoul": "서울",
        "FC Anyang": "안양",
        "Gangwon FC": "강원",
        "Jeju United FC": "제주 SK",
        "Suwon City FC": "수원FC",
        "Incheon United": "인천",
        "Suwon Bluewings": "수원",
        "Jeonnam Dragons": "전남",
        "Seoul E-Land FC": "서울E",
        "Busan I Park": "부산",
        "Bucheon FC 1995": "부천",
        "Asan Mugunghwa": "충남 아산",
        "Seongnam FC": "성남",
        "Gyeongnam FC": "경남",
        "Gimpo Citizen": "김포FC",
        "Cheongju": "충북 청주",
        "Ansan Greeners": "안산",
        "Hwaseong": "화성",
        "Cheonan City": "천안"
    ]
    
    private let outdatedLogoTeams: [String: String] = [
        "Suwon Bluewings": "suwon_bluewings",
        "FC Anyang": "anyang",
        "Jeonnam Dragons": "jeonnam_dragons",
        "Hwaseong": "hwaseong",
        "Cheonan City": "cheonan",
        "Gimpo Citizen": "gimpo",
        "Ulsan Hyundai FC": "ulsan",
        "Jeju United FC": "jeju"
//        "": ""
        // 추가 가능
    ]

    
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
        nameLabel.text = koreanTeamNames[team.team.name] ?? team.team.name
        pointsLabel.text = "승점: \(team.points)"
        recordLabel.text = "경기: \(team.all.played), 승: \(team.all.win), 무: \(team.all.draw), 패: \(team.all.lose), 골득실: \(team.goalsDiff)"
        recordLabel.textAlignment = .center
        if let localImageName = outdatedLogoTeams[team.team.name],
               let image = UIImage(named: localImageName) {
                logoImageView.image = image
            } else {
                logoImageView.kf.setImage(with: URL(string: team.team.logo))
            }
    }
}
