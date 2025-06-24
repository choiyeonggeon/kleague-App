//
//  AdminPostCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/24/25.
//

import UIKit
import SnapKit

class AdminPostCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let reportCountLabel = UILabel()
    private let deletButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)
    
    var onDeleteTapped: (() -> Void)?
    var onEditTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(reportCountLabel)
        contentView.addSubview(deletButton)
        contentView.addSubview(editButton)
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.numberOfLines = 2
        
        reportCountLabel.font = .systemFont(ofSize: 12)
        reportCountLabel.textColor = .systemRed
        
        deletButton.setTitle("삭제", for: .normal)
        deletButton.setTitleColor(.systemRed, for: .normal)
        deletButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        editButton.setTitle("수정", for: .normal)
        editButton.setTitleColor(.blue, for: .normal)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    func configure(with post: Post) {
        titleLabel.text = post.title
        contentLabel.text = post.content
        reportCountLabel.text = "신고: \(post.reportCount)"
    }
    
    @objc private func deleteTapped() {
        onDeleteTapped?()
    }
    
    @objc private func editTapped() {
        onEditTapped?()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(12)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        reportCountLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        deletButton.snp.makeConstraints {
            $0.centerY.equalTo(reportCountLabel)
            $0.trailing.equalToSuperview().inset(12)
        }
        
        editButton.snp.makeConstraints {
            $0.centerY.equalTo(reportCountLabel)
            $0.trailing.equalTo(deletButton.snp.leading).offset(-12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
