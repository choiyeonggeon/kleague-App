//
//  KleagueRankingVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/30/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

class KleagueTableVC:UIViewController {
    
    private let titleLabel = UILabel()
    let tableView = UITableView()
    let segmentedControl = UISegmentedControl(items: ["K리그1", "K리그2"])
    let viewModel = KleagueTableViewModel()
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRank()
        bindViewModel()
        title = "순위"
    }
    
    private func setRank() {
        view.backgroundColor = .white
               view.addSubview(segmentedControl)
               view.addSubview(tableView)
               view.addSubview(titleLabel)
        
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }

               tableView.snp.makeConstraints {
                   $0.top.equalTo(segmentedControl.snp.bottom).offset(16)
                   $0.leading.trailing.bottom.equalToSuperview()
               }

               tableView.register(KleagueTableCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func bindViewModel() {
        segmentedControl.rx.selectedSegmentIndex
            .map { $0 == 0 ? 4689 : 4822 }
            .bind(to: viewModel.leagueID)
            .disposed(by: disposeBag)
        
        viewModel.teams
                  .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: KleagueTableCell.self)) { row, team, cell in
                      cell.configure(with: team, rank: row + 1)
                  }
                  .disposed(by: disposeBag)
    }
    
}
    
   
