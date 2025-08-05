//
//  UsedMarketListVC.swift
//  KleagueApp
//
//  Created by 최영건 on 8/5/25.
//

import UIKit
import SnapKit

class UsedMarketListVC: UIViewController {
    
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
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(writeButton)
        
        searchBar.placeholder = "원하는 물건을 검색해보세요!"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        writeButton.setTitle("+", for: .normal)
        writeButton.setTitleColor(.white, for: .normal)
        writeButton.backgroundColor = .systemBlue
        writeButton.layer.cornerRadius = 25
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
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
}
