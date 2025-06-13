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
            CheeringSong(title: "나의 사랑 나의 수원", lyrics: "오오오오~ 사랑한다\n나의 사랑 나의 수원 오오오오\n좋아한다 오직 너만을 사랑해", youtubeURL: "https://www.youtube.com/watch?v=Oh0xmdjG4GY")
        ])
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "응원가"
        setupSong()
//        bindTableView()
    }
    
    func setupSong() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TeamCell")
    }
    
//    func bindTableView() {
//        teams.bind(to: tableView.rx.items(cellIdentifier: "TeamCell")) { row, model, cell in
//            cell.textLabel?.text = model.teamName
//        }.disposed(by: disposeBag)
//        
//        tableView.rx.modelSelected(CheeringSong.self)
//            .subscribe(onNext: {[weak self] song in
//                let vc = CheeringSongDetailVC(song: song)
//                self?.navigationController?.pushViewController(vc, animated: true)
//            })
//    }
}
