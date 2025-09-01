//
//  UsedProductCell.swift
//  KleagueApp
//
//  Created by 최영건 on 8/15/25.
//

import UIKit
import SnapKit

final class UsedProductCell: UITableViewCell {
    static let identifier = "UsedProductCell"
    
    private let thumbImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let sellerLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:)") }
    
    private func setupUI() {
        contentView.addSubview(thumbImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(sellerLabel)
        
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        thumbImageView.layer.cornerRadius = 6
        thumbImageView.backgroundColor = .systemGray6
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 1
        
        priceLabel.font = .systemFont(ofSize: 14, weight: .bold)
        
        sellerLabel.font = .systemFont(ofSize: 12)
        sellerLabel.textColor = .darkGray
        sellerLabel.numberOfLines = 1
        
        thumbImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(96)
            $0.height.equalTo(72).priority(.high)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(thumbImageView.snp.top)
            $0.leading.equalTo(thumbImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(12)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalTo(titleLabel)
        }
        sellerLabel.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(6)
            $0.leading.equalTo(titleLabel)
            $0.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }
    
    func configure(with product: UsedProduct) {
        titleLabel.text = product.title
        priceLabel.text = "\(product.price)원"
        sellerLabel.text = product.sellerName
        if let first = product.imageUrls.first {
            thumbImageView.setImage(from: first)
        } else {
            thumbImageView.image = nil
        }
    }
}
