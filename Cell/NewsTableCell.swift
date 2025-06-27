//
//  NewsTableCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import UIKit
import SnapKit

class NewsTableCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let sourceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        sourceLabel.font = UIFont.systemFont(ofSize: 12)
        sourceLabel.textColor = .gray
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourceLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        sourceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12) // 꼭 필요!
        }
    }
    
    func configure(with news: News) {
        titleLabel.text = news.title
        sourceLabel.text = news.source
    }
}
