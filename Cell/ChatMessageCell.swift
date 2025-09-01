//
//  ChatMessageCell.swift
//  KleagueApp
//
//  Created by 최영건 on 8/22/25.
//

import UIKit
import SnapKit

class ChatMessageCell: UITableViewCell {
    static let identifier = "ChatMessageCell"
    
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    
    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true
        
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)
        
        bubbleView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.7)
            
            leadingConstraint = $0.leading.equalToSuperview().offset(16).constraint
            trailingConstraint = $0.trailing.equalToSuperview().offset(-16).constraint
        }
        
        messageLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
    }
    
    func configure(with message: ChatMessage, isCurrentUser: Bool) {
        messageLabel.text = message.text
        
        if isCurrentUser {
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            leadingConstraint?.deactivate()
            trailingConstraint?.activate()
        } else {
            bubbleView.backgroundColor = .systemGray5
            messageLabel.textColor = .black
            leadingConstraint?.activate()
            trailingConstraint?.deactivate()
        }
    }
}
