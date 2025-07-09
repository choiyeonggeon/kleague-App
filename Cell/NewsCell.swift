//
//  NewsCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/25/25.
//

import UIKit
import SnapKit

class NewsCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()
    private let sourceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        titleLabel.numberOfLines = 4
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        sourceLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        sourceLabel.textColor = .darkGray
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourceLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(12)
        }
        
        sourceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview().inset(12)
        }
    }
    
    func configure(with news: News) {
        titleLabel.text = news.title
        sourceLabel.text = "출처: \(news.source)"
    }
}
