//
//  NewsCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/25/25.
//

import UIKit
import SnapKit

class NewsCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let sourceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        sourceLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        sourceLabel.textColor = .systemGray
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourceLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        sourceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configure(with news: News) {
        titleLabel.text = news.title
        sourceLabel.text = "출처: \(news.source)"
    }
}
