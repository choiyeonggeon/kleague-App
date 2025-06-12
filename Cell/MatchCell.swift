

//
//  MatchCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/12/25.
//

import UIKit
import SnapKit
import Kingfisher

class MatchCell: UITableViewCell {
    
    private let homeLogoImageView = UIImageView()
    private let awayLogoImageView = UIImageView()
    
    private let homeStackView = UIStackView()
    private let awayStackView = UIStackView()
    
    private let teamStackView = UIStackView()
    private let homeLabel = UILabel()
    private let scoreLabel = UILabel()
    private let awayLabel = UILabel()
    private let statusLabel = UILabel()
        
    private let infoStackView = UIStackView()
    private let dateLabel = UILabel()
    private let refereeLabel = UILabel()
    private let venueLabel = UILabel()
    private let outdatedLogoTeams: [String: String] = [
        "Suwon Bluewings": "suwon_bluewings", "FC Anyang": "anyang",
        "Jeonnam Dragons": "jeonnam_dragons", "Hwaseong": "hwaseong",
        "Cheonan City": "cheonan", "Gimpo Citizen": "gimpo",
        "Ulsan Hyundai FC": "ulsan", "Jeju United FC": "jeju"
    ]
    
    private let koreanTeamNames: [String: String] = [
        "Jeonbuk Motors": "전북", "Daegu FC": "대구",
        "Ulsan Hyundai FC": "울산", "Daejeon Citizen": "대전",
        "Pohang Steelers": "포항", "Gimcheon Sangmu FC": "김천",
        "Gwangju FC": "광주", "FC Seoul": "서울",
        "FC Anyang": "안양", "Gangwon FC": "강원",
        "Jeju United FC": "제주 SK", "Suwon City FC": "수원FC",
        "Incheon United": "인천", "Suwon Bluewings": "수원",
        "Jeonnam Dragons": "전남", "Seoul E-Land FC": "서울E",
        "Busan I Park": "부산", "Bucheon FC 1995": "부천",
        "Asan Mugunghwa": "충남 아산", "Seongnam FC": "성남",
        "Gyeongnam FC": "경남", "Gimpo Citizen": "김포FC",
        "Cheongju": "충북 청주", "Ansan Greeners": "안산",
        "Hwaseong": "화성", "Cheonan City": "천안"
    ]
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with match: Match) {
        homeLabel.text = koreanTeamNames[match.teams.home.name] ?? match.teams.home.name
        awayLabel.text = koreanTeamNames[match.teams.away.name] ?? match.teams.away.name
        scoreLabel.text = "\(match.goals.home ?? 0) : \(match.goals.away ?? 0)"
        
        if let date = ISO8601DateFormatter().date(from: match.fixture.date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateLabel.text = "킥오프: \(formatter.string(from: date))"
        } else {
            dateLabel.text = "킥오프: -"
        }
        
        refereeLabel.text = "심판: \(match.fixture.referee ?? "미정")"
        venueLabel.text = "경기장: \(match.fixture.venue?.name ?? "미정")"
        
        if let localImageName = outdatedLogoTeams[match.teams.home.name],
           let image = UIImage(named: localImageName) {
            homeLogoImageView.image = image
        } else if let homeLogoURL = URL(string: match.teams.home.logo) {
            homeLogoImageView.kf.setImage(with: homeLogoURL)
        } else {
            homeLogoImageView.image = nil
        }
        
        if let localImageName = outdatedLogoTeams[match.teams.away.name],
           let image = UIImage(named: localImageName) {
            awayLogoImageView.image = image
        } else if let awayLogoURL = URL(string: match.teams.away.logo) {
            awayLogoImageView.kf.setImage(with: awayLogoURL)
        } else {
            awayLogoImageView.image = nil
        }
        
        switch match.fixture.status.short {
        case "NS":
            statusLabel.text = "경기 전"
            statusLabel.textColor = .systemBlue
        case"FT":
            statusLabel.text = "경기 종료"
            statusLabel.textColor = .systemRed
            
        case "1H", "2H", "LIVE", "HT":
            if let minutes = match.fixture.status.elapsed {
                statusLabel.text = ("진행 중 \(minutes)분")
            } else {
                statusLabel.text = "경기 진행 중"
            }
            
            statusLabel.backgroundColor = .systemGreen
            
        default:
            statusLabel.text = "상태: \(match.fixture.status.short)"
            statusLabel.backgroundColor = .darkGray
        
        }
    }
    
    private func setupViews() {
        // homeStackView 세팅
        homeStackView.axis = .horizontal
        homeStackView.spacing = 4
        homeStackView.alignment = .center
        homeStackView.addArrangedSubview(homeLogoImageView)
        homeStackView.addArrangedSubview(homeLabel)

        // awayStackView 세팅
        awayStackView.axis = .horizontal
        awayStackView.spacing = 4
        awayStackView.alignment = .center
        awayStackView.addArrangedSubview(awayLogoImageView)
        awayStackView.addArrangedSubview(awayLabel)
        
        // 로고 이미지 뷰 크기 설정
        [homeLogoImageView, awayLogoImageView].forEach {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { $0.size.equalTo(35) }
        }
        
        // 팀 정보 스택뷰 세팅 (홈팀, 스코어, 어웨이팀)
        teamStackView.axis = .horizontal
        teamStackView.distribution = .fillEqually
        teamStackView.alignment = .center
        teamStackView.spacing = 8
        
        teamStackView.addArrangedSubview(homeStackView)
        teamStackView.addArrangedSubview(scoreLabel)
        teamStackView.addArrangedSubview(awayStackView)
        
        [homeLabel, scoreLabel, awayLabel].forEach {
            $0.font = .systemFont(ofSize: 16, weight: .bold)
            $0.textAlignment = .center
            $0.textColor = .black
        }
        
        statusLabel.font = .systemFont(ofSize: 15, weight: .bold)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 4
        statusLabel.layer.masksToBounds = true
        statusLabel.setContentHuggingPriority(.required, for: .horizontal)
        infoStackView.addArrangedSubview(statusLabel)
        
        [dateLabel, refereeLabel, venueLabel].forEach {
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .darkGray
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        
        infoStackView.axis = .vertical
        infoStackView.spacing = 4
        infoStackView.addArrangedSubview(dateLabel)
        infoStackView.addArrangedSubview(refereeLabel)
        infoStackView.addArrangedSubview(venueLabel)
        
        let container = UIStackView(arrangedSubviews: [teamStackView, infoStackView])
        container.axis = .vertical
        container.spacing = 8
        container.alignment = .fill
        
        contentView.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        [homeLabel, awayLabel, scoreLabel, dateLabel, refereeLabel, venueLabel].forEach {
            $0.text = nil
        }
    }
}
