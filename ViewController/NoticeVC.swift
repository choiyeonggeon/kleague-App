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
    let date: String
    let content: String
    let isPinned: Bool
}

class NoticeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let noticeTableView = UITableView()
    private let notices: [Notice] = [
        Notice(title: "[공지] 광고주를 구합니다.", date: "2025.06.12", content: "앱 유지를 하기 위해 소중한 광고주 님을 모십니다.\n홈 화면에 게시해드립니다.", isPinned: true),
        Notice(title: "[공지] 국축여지도 앱 출시",
               date: "2025.06.10",
               content: "안녕하세요! 2025년 6월 10일\n국축여지도 앱을 출시하게 되었습니다!\n앞으로 많은 기능들이 추가될 예정이니\n많은 관심 부탁드립니다.",
               isPinned: true),
        Notice(title: "[공지] 테스트", date: "2025.06.12", content: "테스트 용입니다.", isPinned: false)
    ]
    
    private var sortedNotices: [Notice] {
           return notices.sorted {
               if $0.isPinned == $1.isPinned {
                   return $0.date > $1.date
               }
               return $0.isPinned && !$1.isPinned
           }
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "공지사항"
        setupNoticeView()
    }
    
    private func setupNoticeView() {
        view.addSubview(noticeTableView)
        noticeTableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        noticeTableView.register(NoticeCell.self, forCellReuseIdentifier: "NoticeCell")
        noticeTableView.dataSource = self
        noticeTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedNotices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as? NoticeCell else {
            return UITableViewCell()
        }
        
        let notice = sortedNotices[indexPath.row]
        let fullText = notice.title
        let attributedText = NSMutableAttributedString(string: fullText)
        
        if let range = fullText.range(of: "[공지]") {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttributes([
                    NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
                ], range: nsRange)
        }
        
        cell.titleLabel.attributedText = attributedText
        cell.dateLabel.text = notice.date.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notice = notices[indexPath.row]
        let detailVC = NoticeDetailVC(notice: notice)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
