//
//  CustomerInquiryCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import UIKit

class CustomerInquiryCell: UITableViewCell {
    
    static let identifier = "CustomerInquiryCell"
    
    private let titleLabel = UILabel()
    private let answerStatusLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 1
        
        answerStatusLabel.font = .systemFont(ofSize: 14)
        answerStatusLabel.textColor = .systemBlue
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, answerStatusLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with inquiry: CustomerInquiry) {
        titleLabel.text = inquiry.title
        if let answer = inquiry.answer, !answer.isEmpty {
            answerStatusLabel.text = "답변: 완료"
            answerStatusLabel.textColor = .systemGreen
        } else {
            answerStatusLabel.text = "답변: 미답변"
            answerStatusLabel.textColor = .systemRed
        }
    }
}
