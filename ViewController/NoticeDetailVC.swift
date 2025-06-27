//
//  NoticeDetailVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/11/25.
//

import UIKit
import SnapKit

class NoticeDetailVC: UIViewController {

    private let notice: Notice

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let contentLabel = UILabel()

    init(notice: Notice) {
        self.notice = notice
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "공지 상세"
        view.backgroundColor = .white
        setupLayout()
        configureContent()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        [titleLabel, dateLabel, contentLabel].forEach { contentView.addSubview($0) }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 0

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(titleLabel)
        }
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .gray

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(titleLabel)
            $0.bottom.equalToSuperview().inset(24)
        }
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.numberOfLines = 0
        contentLabel.textColor = .black
    }

    private func configureContent() {
        let attributedTitle = NSMutableAttributedString(string: notice.title)
        if let range = notice.title.range(of: "[공지]") {
            let nsRange = NSRange(range, in: notice.title)
            attributedTitle.addAttributes([
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.boldSystemFont(ofSize: 20)
            ], range: nsRange)
        }
        titleLabel.attributedText = attributedTitle

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = formatter.string(from: notice.date)

        contentLabel.text = notice.content
    }
}
