//
//  NoticeVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/10/25.
//

import UIKit
import SnapKit

struct Notice {
    let title: String
    let content: String
}

class NoticeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let noticeTableView = UITableView()
    private let notices: [Notice] = [
        Notice(title: "[공지] 국축여지도 앱 출시", content: "안녕하세요! 2025년 6월 10일, 국축여지도 앱을 출시하게 되었습니다. 앞으로 많은 기능들이 추가될 예정이니 많은 관심부탁드립니다.")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "공지사항"
        setupNoticeView()
    }
    
    private func setupNoticeView() {
        view.addSubview(noticeTableView)
        noticeTableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        noticeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "NoticeCell")
        noticeTableView.dataSource = self
        noticeTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath)
        let notice = notices[indexPath.row]
        
        let fullText = notice.title
        let attributedText = NSMutableAttributedString(string: fullText)
        
        if let range = fullText.range(of: "[공지]") {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttributes([
                    NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
                ], range: nsRange)
        }
        
        cell.textLabel?.attributedText = attributedText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notice = notices[indexPath.row]
        let detailVC = NoticeDetailVC(notice: notice)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
