//
//  UsedMarketDetailVC.swift
//  KleagueApp
//
//  Created by 최영건 on 8/12/25.
//

import UIKit
import SnapKit

class UsedMarketDetailVC:UIViewController {
    
    private let productImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionTextView = UITextView()
    private let sellerLabel = UILabel()
    private let chatButton = UIButton()
    
    var productTitle: String?
    var productPrice: String?
    var productDescription: String?
    var productImage: UIImage?
    var productImageUrl: String?
    var sellerName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "상품 상세"
        
        [productImageView, titleLabel, priceLabel, descriptionTextView, sellerLabel, chatButton].forEach {
            view.addSubview($0)
        }
        
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 8
        productImageView.backgroundColor = .systemGray6
        
        titleLabel.font = .boldSystemFont(ofSize: 20)
        priceLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        priceLabel.textColor = .systemRed
        
        descriptionTextView.font = .systemFont(ofSize: 16)
        descriptionTextView.isEditable = false
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.cornerRadius = 6
        
        sellerLabel.font = .systemFont(ofSize: 14)
        sellerLabel.textColor = .darkGray
        
        chatButton.setTitle("채팅하기", for: .normal)
        chatButton.backgroundColor = .systemBlue
        chatButton.setTitleColor(.white, for: .normal)
        chatButton.layer.cornerRadius = 8
        
        productImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(220)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(150)
        }
        
        sellerLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        chatButton.snp.makeConstraints {
            $0.top.equalTo(sellerLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }
    
    private func configureData() {
        titleLabel.text = productTitle ?? "제목 없음"
        priceLabel.text = productPrice ?? "가격 없음"
        descriptionTextView.text = productDescription ?? "설명 없음"
        sellerLabel.text = sellerName != nil ? "판매자: \(sellerName!)" : "판매자 정보 없음"
        
        if let img = productImage {
            productImageView.image = img
        } else {
            productImageView.setImage(from: productImageUrl)
        }
    }
}
