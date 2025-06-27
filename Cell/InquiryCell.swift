//
//  InquiryCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import UIKit

class InquiryCell: UITableViewCell {
    static let identifier = "InquiryCell"
    
    private let titleLabel = UILabel()
    private let answerStatusLabel = UILabel()
    let authorLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        answerStatusLabel.font = .systemFont(ofSize: 13)
        answerStatusLabel.textColor = .systemBlue
        
        authorLabel.font = .systemFont(ofSize: 13)
        authorLabel.textColor = .darkGray
        
        let topStack = UIStackView(arrangedSubviews: [titleLabel, answerStatusLabel])
        topStack.axis = .horizontal
        topStack.distribution = .equalSpacing
        
        let verticalStack = UIStackView(arrangedSubviews: [topStack, authorLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 4
        
        contentView.addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with inquiry: CustomerInquiry) {
        titleLabel.text = inquiry.title
        authorLabel.text = "문의자: \(inquiry.authorUid)"
        
        if let answer = inquiry.answer, !answer.isEmpty {
            answerStatusLabel.text = "답변 완료"
            answerStatusLabel.textColor = .systemBlue
        } else {
            answerStatusLabel.text = "미답변"
            answerStatusLabel.textColor = .systemGray
        }
    }
}
