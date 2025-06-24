//
//  HomeVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//

import UIKit
import SnapKit
import SafariServices

struct News {
    let title: String
    let source: String
    let url: String
}

class HomeVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    
    let newsList: [News] = [
        News(title: "영국 매체 방한 앞둔 뉴캐슬, 수원 삼성 박승수 영입 추진",
             source: "뉴시스",
             url: "https://www.newsis.com/view/NISX20250624_0003225657"),
        News(title: "기성용, 포항 이적 추진에…서울 팬 반발 “레전드를 이렇게 대우하냐”, 주말 양 팀 맞대결",
             source: "스포츠네이버",
             url: "https://m.sports.naver.com/kfootball/article/468/0001156799")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupTableView()
        title = "홈"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NewsCell")
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
    }
    
    private func setupUI() {
        
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsCell.self, forCellReuseIdentifier: "NewsCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .singleLine
    }
}

// MARK: - UITableViewDataSource
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsCell else {
            return UITableViewCell()
        }
        
        let news = newsList[indexPath.row]
        cell.configure(with: news)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = newsList[indexPath.row]
        if let url = URL(string: news.url) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
