//
//  ChatMessageCell.swift
//  KleagueApp
//
//  Created by 최영건 on 8/22/25.
//

//
//  ChatMessageCell.swift
//  KleagueApp
//

import UIKit
import SnapKit

final class ChatMessageCell: UITableViewCell {
    
    static let identifier = "ChatMessageCell"
    
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    
    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        bubbleView.layer.cornerRadius = 12
        bubbleView.clipsToBounds = true
        
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)
        
        bubbleView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.width.lessThanOrEqualTo(250)
            leadingConstraint = $0.leading.equalToSuperview().constraint
            trailingConstraint = $0.trailing.equalToSuperview().constraint
        }
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
    
    func configure(with message: ChatMessage, isCurrentUser: Bool) {
        messageLabel.text = message.text
        bubbleView.backgroundColor = isCurrentUser ? .systemBlue : .lightGray
        messageLabel.textColor = isCurrentUser ? .white : .black
        
        if isCurrentUser {
            leadingConstraint?.deactivate()
            trailingConstraint?.activate()
        } else {
            trailingConstraint?.deactivate()
            leadingConstraint?.activate()
        }
    }
}
