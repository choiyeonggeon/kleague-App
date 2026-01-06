//
//  AdminPostCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/24/25.
//

import UIKit

class AdminPostCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let suspendButton = UIButton(type: .system)   // 7일 정지 버튼
    
    var onEditTapped: (() -> Void)?
    var onSuspendTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 1
        
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.numberOfLines = 2
        contentLabel.textColor = .darkGray
        
        editButton.setTitle("수정", for: .normal)
        editButton.setTitleColor(.systemBlue, for: .normal)
        editButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        
        deleteButton.setTitle("삭제", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        
        suspendButton.setTitle("7일 정지", for: .normal)
        suspendButton.setTitleColor(.systemOrange, for: .normal)
        suspendButton.addTarget(self, action: #selector(didTapSuspend), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [editButton, deleteButton, suspendButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, contentLabel, buttonStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        
        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with post: Post) {
        let reportCountText = post.reportCount
        titleLabel.text = "🔴 \(post.title) (\(reportCountText)회 신고)"
        contentLabel.text = post.content
    }
    
    @objc private func didTapEdit() {
        onEditTapped?()
    }
    
    @objc private func didTapDelete() {
        onDeleteTapped?()
    }
    
    @objc private func didTapSuspend() {
        onSuspendTapped?()
    }
}
