////
////  CheeringSongVC.swift
////  KleagueApp
////
////  Created by 최영건 on 6/12/25.
////
//
//import UIKit
//import SnapKit
//import RxSwift
//import RxCocoa
//
//class CheeringTeamListVC: UIViewController {
//    
//    let tableView = UITableView()
//    let disposeBag = DisposeBag()
//    
//    let teams = BehaviorRelay<[TeamCheeringSongs]>(value: [
//        TeamCheeringSongs(teamName: "수원", songs: [
//            CheeringSong(title: "나의 사랑 나의 수원",
//                         lyrics: """
//                                오오오오~ 사랑한다
//                                나의 사랑 나의 수원
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=Oh0xmdjG4GY"),
//            CheeringSong(title: "데스파시토",
//                         lyrics: """
//                                폭풍 속에 이 길을 걸어가
//                                기다리는 우리들의 저 꿈에
//                                너와 나의 노랠 가득 담아
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=3k8QKfSo1Zo"),
//            CheeringSong(title: "막을 수 없는 이 사랑",
//                         lyrics: """
//                                하루하루가 지날 때마다
//                                기다려왔던 이 시간
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=jJn_EoARbt4"),
//            CheeringSong(title: "Ale Ale 수원 Ale",
//                         lyrics: """
//                                Ale Ale 수원 Ale
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=Avsvyvsa2Ck"),
//            CheeringSong(title: "나의 마음에 환희를 또 한번 더",
//                         lyrics: """
//                                나의 마음에 환희를 또 한번 더
//                                하얗게 눈이 내리던 그날처럼
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=BkmVPlQ0lDE"),
//            CheeringSong(title: "Against TV Football",
//                         lyrics: """
//                                TV 채널마다 가득한 저 먼 곳의
//                                90분의 이야기는 전혀 와닿지 않아
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=awL-cFcDqpE"),
//            CheeringSong(title: "Vamos Suwon Campeon",
//                         lyrics: """
//                                우리 함께 승리로 나아가
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=avGrlrtHzMM"),
//            CheeringSong(title: "Vamos Campeon",
//                         lyrics: """
//                                모두의 마음을 모아서
//                                저 높은 곳을 향해서
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: 형도 / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=QFVV28lFF6Y&t=27s"),
//            CheeringSong(title: "수원의 열두 번째",
//                         lyrics: """
//                                수원의 열두 번째
//                                언제나 우리가 널 지킨다
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=OLSuTzScX8s"),
//            CheeringSong(title: "개선행진곡",
//                         lyrics: """
//                                알레 수원 블루윙
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=XtBuBLIgZ1Q"),
//            CheeringSong(title: "지지자는 승리를 원한다",
//                         lyrics: """
//                                우리가 원하는 건 승리
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=2FiICosmoDQ"),
//            CheeringSong(title: "우리는 수원 블루윙",
//                         lyrics: """
//                                영원히 승리하리라.
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: 이랑블루 / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=tyOzwCAZyp8"),
//            CheeringSong(title: "로맨틱 시티 ( Romantic City )",
//                         lyrics: """
//                                손뼉을 치며 이 거리에 낭만을 만들자
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=IK1ibNCLyM0"),
//            CheeringSong(title: "날아가 블루윙",
//                         lyrics: """
//                                나의 사랑 어디라도 따라
//                                너를 따라 내 사랑을 담아
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=T2L5YfGaENc"),
//            CheeringSong(title: "가자 가자 블루윙",
//                         lyrics: """
//                                가자 가자 블루윙
//                                승리는 모두의 힘으로
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=y0pNtlgV91E&t=7s"),
//            CheeringSong(title: "오 나의 수원",
//                         lyrics: """
//                                 나의 수원
//                                 
//                                 자세한 가사는 아래의 동영상에서...
//                                 출처: ekdmz / YouTube
//                                 """,
//                         youtubeURL: "https://www.youtube.com/watch?v=54onjjl4i3M"),
//            CheeringSong(title: "사랑하고 싶어",
//                         lyrics: """
//                                 우린 수원 영원히 수원 랄라라 
//                                 자세한 가사는 아래의 동영상에서... 
//                                 출처: ekdmz / YouTube
//                                 """,
//                         youtubeURL: "https://www.youtube.com/watch?v=GPSUsRK8SuQ"),
//            CheeringSong(title: "오레, 오오",
//                         lyrics: """
//                                 오레~ 오오
//                                 """,
//                         youtubeURL: "https://www.youtube.com/watch?v=EES9tCQOXQ4"),
//            CheeringSong(title: "우리는 수원",
//                         lyrics: """
//                                 우리는 수원 
//                                 
//                                 자세한 가사는 아래의 동영상에서...
//                                 출처: ekdmz / YouTube
//                                 """,
//                         youtubeURL: "https://www.youtube.com/watch?v=px1uo_6fju4"),
//            CheeringSong(title: "이 사랑에 후회는 없다",
//                         lyrics: """
//                                 친구들과 함꼐 너를 위해 노래해
//                                 
//                                 자세한 가사는 아래의 동영상에서...
//                                 출처: ekdmz / YouTube
//                                 """,
//                         youtubeURL: "https://www.youtube.com/watch?v=Qobb-KuFaQs"),
//            CheeringSong(title: "이 사랑은 변하지 않아",
//                         lyrics: """
//                                오십 번의 겨울이 지나도
//                                이 사랑은 변하지 않아
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: ekdmz / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=MQh4OrePk4o"),
//            CheeringSong(title: "제도의 심장부에서",
//                         lyrics: """
//                                 제도의 푸른 하늘에
//                                 청백적의 기를 높여라
//                                 
//                                 자세한 가사는 아래의 동영상에서...
//                                 출처: ekdmz / YouTube
//                                 """,
//                         youtubeURL: "https://www.youtube.com/watch?v=iJwMBAV5K5I"),
//            CheeringSong(title: "청백적의 챔피언",
//                         lyrics: """
//                                어디라도 꿈속이라도 널 따라가
//                                
//                                자세한 가사는 아래의 동영상에서...
//                                출처: 직관의 맛 / YouTube
//                                """,
//                         youtubeURL: "https://www.youtube.com/watch?v=SSIhk2lCUrA&t=10s")
//            
//        ]),
//        
//        TeamCheeringSongs(teamName: "FC서울", songs: [
//            
//        ]),
//        
//        TeamCheeringSongs(teamName: "인천", songs: [
//            
//        ]),
//        
//        TeamCheeringSongs(teamName: "전북", songs: [
//            
//        ]),
//        
//        TeamCheeringSongs(teamName: "울산", songs: [
//            
//        ]),
//        
//        TeamCheeringSongs(teamName: "성남", songs: [
//            
//        ]),
//        
//        TeamCheeringSongs(teamName: "안양", songs: [
//            
//        ])
//    ])
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        title = "응원가"
//        setupSong()
//        bindTableView()
//    }
//    
//    func setupSong() {
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TeamCell")
//    }
//    
//    func bindTableView() {
//        teams.bind(to: tableView.rx.items(cellIdentifier: "TeamCell")) { row, model, cell in
//            cell.textLabel?.text = model.teamName
//        }.disposed(by: disposeBag)
//        
//        tableView.rx.modelSelected(TeamCheeringSongs.self)
//            .subscribe(onNext: { [weak self] team in
//                let vc = CheeringSongListVC(team: team)
//                self?.navigationController?.pushViewController(vc, animated: true)
//            }).disposed(by: disposeBag)
//    }
//}
