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
        setupCardStyle()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCardStyle() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.masksToBounds = false
    }
    
    private func setupUI() {
        titleLabel.numberOfLines = 3
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .navy
        
        sourceLabel.font = .systemFont(ofSize: 12)
        sourceLabel.textColor = .gray
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(sourceLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(14)
        }
        
        sourceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.bottom.equalToSuperview().inset(14)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        sourceLabel.text = nil
        transform = .identity
    }
    
    func configure(with news: News) {
        titleLabel.text = news.title
        sourceLabel.text = "출처: \(news.source)"
    }
}
