//
//  HomeVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//

import UIKit
import SnapKit

class HomeVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let comingSoonLabel = UILabel()
    //    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        title = "홈"
        
    }
    
    private func setupUI() {
        
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(90)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        comingSoonLabel.text = "서비스 준비 중..."
        comingSoonLabel.textColor = .lightGray
        comingSoonLabel.textAlignment = .center
        comingSoonLabel.font = UIFont(name: "GmarketSansTTFMedium", size: 20)
        view.addSubview(comingSoonLabel)
        
        comingSoonLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
