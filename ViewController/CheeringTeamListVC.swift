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
            CheeringSong(title: "나의 사랑 나의 수원", lyrics: "오오오오~ 사랑한다\n나의 사랑 나의 수원 오오오오\n좋아한다 오직 너만을 사랑해", youtubeURL: "https://www.youtube.com/watch?v=Oh0xmdjG4GY"),
            CheeringSong(title: "데스파시토", lyrics: "너만이 우리의 가슴을 뛰게 해\n이곳에 있어 프렌테 트리콜로\n(트리콜로! 트리콜로!)\n달리는 심장에 리듬을 함께해\n블루윙 수원 우러 너와 나\n싸워 나아가 꿈을 향해 나아가 자유로와 이 푸른 심장은\n이어나가 우리 꿈의 사랑\n폭풍 속에 이 길을 걸어가\n기다리는 우리들의 저 꿈에\n너와 나의 노랠 가득 담아\n청백적 거리와 친구들과\n우리의 노래들과 우리의 이야기와\n블루윙 우리의 사랑들과 우리의 노래들과\n우리의 눈물들과", youtubeURL: "https://www.youtube.com/watch?v=3k8QKfSo1Zo")
        ]),
        TeamCheeringSongs(teamName: "FC서울", songs: [])
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
