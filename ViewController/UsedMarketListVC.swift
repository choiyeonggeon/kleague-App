//
//  UsedMarketListVC.swift
//  KleagueApp
//
//  Created by 최영건 on 8/5/25.
//

import UIKit
import SnapKit

class UsedMarketListVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let writeButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "중고 거래"
        
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(writeButton)
        
        searchBar.placeholder = "원하는 물건을 검색해보세요!"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        writeButton.setTitle("+", for: .normal)
        writeButton.setTitleColor(.white, for: .normal)
        writeButton.backgroundColor = .systemBlue
        writeButton.layer.cornerRadius = 25
        writeButton.addTarget(self, action: #selector(didTapWriteButton), for: .touchUpInside)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        writeButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(30)
        }
    }
    
    @objc private func didTapWriteButton() {
        
    }
}
