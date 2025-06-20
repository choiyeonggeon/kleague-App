//
//  CheeringSongVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/12/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CheeringTeamListVC: UIViewController {
    
    let tableView = UITableView()
    let disposeBag = DisposeBag()
    
    let teams = BehaviorRelay<[TeamCheeringSongs]>(value: [
        TeamCheeringSongs(teamName: "수원", songs: [
            CheeringSong(title: "나의 사랑 나의 수원",
                         lyrics: "오오오오~ 사랑한다\n나의 사랑 나의 수원 오오오오\n좋아한다 오직 너만을 사랑해",
                         youtubeURL: "https://www.youtube.com/watch?v=Oh0xmdjG4GY"),
            
            CheeringSong(title: "데스파시토",
                         lyrics: "너만이 우리의 가슴을 뛰게 해\n이곳에 있어 프렌테 트리콜로\n(트리콜로! 트리콜로!)\n달리는 심장에 리듬을 함께해\n블루윙 수원 우러 너와 나\n싸워 나아가 꿈을 향해 나아가 자유로와 이 푸른 심장은\n이어나가 우리 꿈의 사랑\n폭풍 속에 이 길을 걸어가\n기다리는 우리들의 저 꿈에\n너와 나의 노랠 가득 담아\n청백적 거리와 친구들과\n우리의 노래들과 우리의 이야기와\n블루윙 우리의 사랑들과 우리의 노래들과\n우리의 눈물들과",
                         youtubeURL: "https://www.youtube.com/watch?v=3k8QKfSo1Zo"),
            
            CheeringSong(title: "막을 수 없는 이 사랑",
                         lyrics: "하루하루가 지날 때마다\n기다려왔던 이 시간\n챔피언 널 만나러 갈 때마다\n다른 건 모두 잊혀가\n청백적의 챔피언 지금 너에게 달려가\nVamos Vamos 수원\n막을 수 없는 이 사랑",
                         youtubeURL: "https://www.youtube.com/watch?v=jJn_EoARbt4"),
            
            CheeringSong(title: "Ale Ale 수원 Ale",
                         lyrics: "Ale Ale 수원 Ale(수원)\nAle Ale 수원 Ale(수원)\nAle Ale 수원 Ale\nAle 수원 Ale(어이어이어이어이어이)",
                         youtubeURL: "https://www.youtube.com/watch?v=Avsvyvsa2Ck"),
            
            CheeringSong(title: "나의 마음에 환희를 또 한번 더",
                         lyrics: "나의 마음에 환희를 또 한번 더(한번 더)\n하얗게 눈이 내리던 그날처럼(그날처럼)\n나의 마음에 소원을 또 한번 더\n저 하늘의 끝으로 날 데려가\n라 반다와\n저 바다를 넘어 여행을 떠나자",
                         youtubeURL: "https://www.youtube.com/watch?v=BkmVPlQ0lDE"),
            
            CheeringSong(title: "Against TV Football",
                         lyrics: "TV 채널마다 가득한 저 먼 곳의\n90분의 이야기는 전혀 와닿지 않아\n우만의 거리 위에 너와 나의 집에서\n우리들의 드라마를 계속 이어나가자",
                         youtubeURL: "https://www.youtube.com/watch?v=awL-cFcDqpE"),
            
            CheeringSong(title: "Vamos Suwon Campeon",
                         lyrics: "Vamos 수원 Cpampeon\n우리 함께 승리로 나아가",
                         youtubeURL: "https://www.youtube.com/watch?v=avGrlrtHzMM"),
            
            CheeringSong(title: "Vamos Campeon",
                         lyrics: "자 가자 나의 Campeon\n우만의 친구들이\n널 따라가\n모두의 마음을 모아서\n저 높은 곳을 향해서\n다함께 싸워나가자\nVamos Campeon 나아가자 승리의 순간으로\nVamos Campeon 우리들의 노래는 멈추지 않아",
                         youtubeURL: "https://www.youtube.com/watch?v=QFVV28lFF6Y&t=27s"),
            
            CheeringSong(title: "수원의 열두 번째",
                         lyrics: "수원의 열두 번째\n언제나 우리가 널 지킨다\n수원 그 두 글자를!\n쉬지 않는 가슴 속에 새긴다\n오 알레 오 알레 알레 수원\n오 알레 오 알레 알레 오\n오 알레 오 알레 알레 수원\n오 알레 오~\n오 알레 알레 오",
                         youtubeURL: "https://www.youtube.com/watch?v=OLSuTzScX8s"),
            
            CheeringSong(title: "개선행진곡",
                         lyrics: "알레 수원 블루윙 오오오오오\n수원 블루윙 오오오 오오오 수원",
                         youtubeURL: "https://www.youtube.com/watch?v=XtBuBLIgZ1Q"),
            
            CheeringSong(title: "지지자는 승리를 원한다",
                         lyrics: "우리가 원하는 건 승리\nOO의 숨통을 조여라(조여조여)\n영원한 승리의 푸른 날개\nOO의 하늘을 덮는다\n승리를 노래하자 수원!\n오오오 오오오 오오오\n오오오 오오 오오오오 오오오 오오오 오오오",
                         youtubeURL: "https://www.youtube.com/watch?v=2FiICosmoDQ"),
            
            CheeringSong(title: "우리는 수원 블루윙",
                         lyrics: "우리는 수원 블루윙 우리는 수원 블루윙\n영원히 승리하리라 수원 삼성 블루윙\n오오오 오오 오오오 오오오 오오 오오오\n오오오 오오 오오오\n수원 삼성 블루윙",
                         youtubeURL: "https://www.youtube.com/watch?v=tyOzwCAZyp8"),
            
            CheeringSong(title: "로맨틱 시티 ( Romantic City )",
                         lyrics: "손뼉을 치며 이 거리에 낭만을 만들자\n장안에서 권선까지\n팔달에서 영통까지",
                         youtubeURL: "https://www.youtube.com/watch?v=IK1ibNCLyM0"),
            
            CheeringSong(title: "날아가 블루윙",
                         lyrics: "나의 사랑 어디라도 따라\n너를 따라 내 사랑을 담아\n날아가 블루윙 저 하늘 끝까지\n청백적 행복의 날개로\n알레 오 알레알레 오 알레 오 알레알레 오",
                         youtubeURL: "https://www.youtube.com/watch?v=T2L5YfGaENc")
            
        ]),
        
        TeamCheeringSongs(teamName: "FC서울", songs: [
            
        ]),
        
        TeamCheeringSongs(teamName: "인천", songs: [
            
        ]),
        
        TeamCheeringSongs(teamName: "전북", songs: [
            
        ]),
        
        TeamCheeringSongs(teamName: "울산", songs: [
            
        ]),
        
        TeamCheeringSongs(teamName: "성남", songs: [
            
        ]),
        
        TeamCheeringSongs(teamName: "안양", songs: [
            
        ])
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "응원가"
        setupSong()
        bindTableView()
    }
    
    func setupSong() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TeamCell")
    }
    
    func bindTableView() {
        teams.bind(to: tableView.rx.items(cellIdentifier: "TeamCell")) { row, model, cell in
            cell.textLabel?.text = model.teamName
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(TeamCheeringSongs.self)
            .subscribe(onNext: { [weak self] team in
                let vc = CheeringSongListVC(team: team)
                self?.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
    }
}
