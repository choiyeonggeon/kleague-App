//
//  CheeringSongListVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/13/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CheeringSongListVC: UIViewController {
    
    let tableView = UITableView()
    let disposeBag = DisposeBag()
    let team: TeamCheeringSongs
    let songsRelay: BehaviorRelay<[CheeringSong]>
    
    init(team: TeamCheeringSongs) {
        self.team = team
        self.songsRelay = BehaviorRelay(value: team.songs)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
