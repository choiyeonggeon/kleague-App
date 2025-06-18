//
//  PostCell.swift
//  gugchugyeojido
//
//  Created by 최영건 on 6/16/25.
//

import UIKit
import SnapKit

class PostCell: UITableViewCell {
    
    var onReportButtonTapped: (() -> Void)?
    
    private let titleLabel = UILabel()
    private let previewLabel = UILabel()
    private let infoLabel = UILabel()
    private let authorLabel = UILabel()
    private let timeLabel = UILabel()
    private let reportButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupPostUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with post: Post) {
        titleLabel.text = "📌" + post.title
        previewLabel.text = post.preview
        infoLabel.text = "❤️ \(post.likes)   👍 댓글 \(post.commentsCount)"
        authorLabel.text = "작성자: \(post.author)"
        timeLabel.text = "\(post.createdAt)"
    }
    
    private func setupPostUI() {
        
        reportButton.setTitle("신고", for: .normal)
        reportButton.setTitleColor(.systemRed, for: .normal)
        reportButton.titleLabel?.font = .systemFont(ofSize: 13)
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
        contentView.addSubview(reportButton)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, previewLabel, infoLabel, authorLabel, timeLabel])
        stack.axis = .vertical
        stack.spacing = 8
        contentView.addSubview(stack)
        
        reportButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(12)
        }
        
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
            $0.trailing.equalTo(reportButton.snp.leading).offset(-8)
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        previewLabel.font = .systemFont(ofSize: 14)
        previewLabel.textColor = .darkGray
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = .gray
        authorLabel.font = .systemFont(ofSize: 13)
        authorLabel.textColor = .lightGray
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .lightGray
    }
    
    @objc private func reportTapped() {
        onReportButtonTapped?()
    }
    
}
