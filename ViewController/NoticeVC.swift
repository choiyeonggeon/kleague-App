//
//  NoticeVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/10/25.
//

import UIKit
import FirebaseFirestore
import SnapKit

class NoticeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private var notices: [Notice] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "공지사항"

        setupTableView()
        fetchNotices()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NoticeCell.self, forCellReuseIdentifier: "NoticeCell")
    }

    private func fetchNotices() {
        Firestore.firestore().collection("notices")
            .order(by: "isPinned", descending: true)
            .order(by: "date", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("공지사항 불러오기 실패: \(error.localizedDescription)")
                    return
                }
                self?.notices = snapshot?.documents.compactMap { Notice(from: $0) } ?? []
                self?.tableView.reloadData()
            }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as? NoticeCell else {
            return UITableViewCell()
        }

        let notice = notices[indexPath.row]
        let fullText = notice.title
        let attributedText = NSMutableAttributedString(string: fullText)

        if let range = fullText.range(of: "[공지]") {
            let nsRange = NSRange(range, in: fullText)
            attributedText.addAttributes([
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.boldSystemFont(ofSize: 17)
            ], range: nsRange)
        }

        cell.titleLabel.attributedText = attributedText

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        cell.dateLabel.text = formatter.string(from: notice.date)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notice = notices[indexPath.row]
        let detailVC = NoticeDetailVC(notice: notice)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
