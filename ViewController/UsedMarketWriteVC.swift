//
//  UsedMarketWriteVC.swift
//  KleagueApp
//
//  Created by 최영건 on 8/11/25.
//

import UIKit
import SnapKit

class UsedMarketWriteVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let titleField = UITextField()
    private let priceField = UITextField()
    private let contentTextView = UITextView()
    private let imageView = UIImageView()
    private let submitButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupUI() {
        
        view.backgroundColor = .white
        navigationItem.title = "거래 글쓰기"
        
        [titleField, priceField, contentTextView, imageView, submitButton].forEach {
            view.addSubview($0)
        }
        
        titleField.placeholder = "제목"
        priceField.placeholder = "가격 (숫자만)"
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1
        contentTextView.text = "상세 설명을 입력해주세요."
        
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleAspectFit
        
        submitButton.setTitle("등록하기", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.layer.cornerRadius = 8
        
        titleField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        priceField.snp.makeConstraints {
            $0.top.equalTo(titleField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(priceField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(150)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(200)
        }
        
        submitButton.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }
}
