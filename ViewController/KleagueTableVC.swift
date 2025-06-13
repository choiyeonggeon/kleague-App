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

class KleagueTableVC: UIViewController {

    private let titleLabel = UILabel()
    let tableView = UITableView()
    let segmentedControl = UISegmentedControl(items: ["K리그1", "K리그2"])
    let viewModel = KleagueTableViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        setupUI()
        bindViewModel()
        title = "순위"
    }

    private func setupUI() {

        view.addSubview(titleLabel)
        view.addSubview(segmentedControl)
        view.addSubview(tableView)

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

        // ✅ 핵심 설정들
        tableView.register(KleagueTableCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .white
    }

    private func bindViewModel() {
        segmentedControl.rx.selectedSegmentIndex
            .map { $0 == 0 ? 292 : 293 }
            .bind(to: viewModel.leagueID)
            .disposed(by: disposeBag)

        viewModel.standings
            .do(onNext: { teams in
                print("💡 받은 팀 수: \(teams.count)")
            })
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: KleagueTableCell.self)) { row, team, cell in
                cell.configure(with: team)
            }
            .disposed(by: disposeBag)
    }
}
