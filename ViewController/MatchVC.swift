//
//  MatchVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MatchVC: UIViewController {
    
    private let titleLabel = UILabel()
    let segmentedControl1 = UISegmentedControl(items: ["K리그1", "K리그2"])
    let MatchTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setMatchData()
        title = "경기/결과"
    }
    
    private func setMatchData() {
        view.addSubview(segmentedControl1)
        view.addSubview(MatchTableView)
        
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        segmentedControl1.selectedSegmentIndex = 0
        segmentedControl1.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        
        MatchTableView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl1.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        

    }
    
}
