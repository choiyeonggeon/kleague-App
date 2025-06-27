//
//  CommentCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/18/25.
//

import UIKit
import SnapKit

class CommentCell: UITableViewCell {
    
    let authorLabel = UILabel()
    let reportButton = UIButton(type: .system)
    let commentLabel = UILabel()
    let timeLabel = UILabel()
    
    var onReportTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        authorLabel.font = .boldSystemFont(ofSize: 14)
        
        reportButton.setTitle("신고", for: .normal)
        reportButton.setTitleColor(.systemRed, for: .normal)
        reportButton.titleLabel?.font = .systemFont(ofSize: 14)
        
        commentLabel.font = .systemFont(ofSize: 14)
        commentLabel.numberOfLines = 0
        
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .gray
        
        // authorLabel과 reportButton을 가로로 배치
        let topStack = UIStackView(arrangedSubviews: [authorLabel, UIView(), reportButton])
        topStack.axis = .horizontal
        topStack.alignment = .center
        
        let mainStack = UIStackView(arrangedSubviews: [topStack, commentLabel, timeLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 4
        
        contentView.addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        timeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }
        
        reportButton.snp.makeConstraints {
            $0.width.equalTo(44)
            $0.height.equalTo(24)
        }
    }
    
    private func setupActions() {
        reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
    }
    
    @objc private func reportButtonTapped() {
        onReportTapped?()
    }
    
    func configure(author: String, text: String, time: String) {
        authorLabel.text = author
        commentLabel.text = text
        timeLabel.text = time
    }
}
