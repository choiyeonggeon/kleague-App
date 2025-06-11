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
    }

    private func setupLayout() {
        // 1. scrollView → view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        // 2. contentView → scrollView
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 3. contentLabel → contentView
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20) // 스크롤 가능하도록 bottom 추가
        }

        // 4. Label 스타일 설정
        contentLabel.text = notice.content
        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 17)
        contentLabel.textColor = .black
    }
}
