//
//  AllNewsListVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import UIKit
import SnapKit
import Foundation
import FirebaseAuth
import FirebaseFirestore
import SafariServices

class AllNewsListVC: UIViewController {
    private var allNews: [News] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "전체 뉴스"
        setupTableView()
        fetchAllNews()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        tableView.register(NewsTableCell.self, forCellReuseIdentifier: "NewsCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    private func fetchAllNews() {
        Firestore.firestore()
            .collection("news")
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self?.allNews = documents.compactMap {
                    let data = $0.data()
                    return News(
                        title: data["title"] as? String ?? "",
                        source: data["source"] as? String ?? "",
                        url: data["url"] as? String ?? ""
                    )
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
    }
}

extension AllNewsListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { allNews.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let news = allNews[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableCell
        cell.configure(with: news)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = allNews[indexPath.row]
        if let url = URL(string: news.url) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
}
