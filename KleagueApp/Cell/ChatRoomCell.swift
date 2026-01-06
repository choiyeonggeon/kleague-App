//
//  ChatRoomCell.swift
//  KleagueApp
//
//  Created by 최영건 on 9/8/25.
//

import UIKit
import SnapKit

final class ChatRoomCell: UITableViewCell {
    
    static let identifier = "ChatRoomCell"
    
    private let titleLabel = UILabel()
    private let lastMessageLabel = UILabel()
    private let timeLabel = UILabel()
    private let unreadCountLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        lastMessageLabel.font = .systemFont(ofSize: 14)
        lastMessageLabel.textColor = .darkGray
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .lightGray
        unreadCountLabel.font = .systemFont(ofSize: 12)
        unreadCountLabel.textColor = .white
        unreadCountLabel.backgroundColor = .systemRed
        unreadCountLabel.textAlignment = .center
        unreadCountLabel.layer.cornerRadius = 10
        unreadCountLabel.clipsToBounds = true
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(unreadCountLabel)
        
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview().inset(12); $0.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-8) }
        lastMessageLabel.snp.makeConstraints { $0.top.equalTo(titleLabel.snp.bottom).offset(4); $0.leading.trailing.equalToSuperview().inset(12); $0.bottom.equalToSuperview().inset(12) }
        timeLabel.snp.makeConstraints { $0.top.trailing.equalToSuperview().inset(12) }
        unreadCountLabel.snp.makeConstraints { $0.centerY.equalTo(titleLabel); $0.trailing.equalToSuperview().inset(12); $0.width.height.equalTo(20) }
    }
    
    func configure(with room: ChatRoom, unreadCount: Int) {
        titleLabel.text = room.title
        lastMessageLabel.text = room.lastMessage ?? "메시지가 없습니다."
        
        if let date = room.lastUpdatedAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            timeLabel.text = formatter.string(from: date)
        } else {
            timeLabel.text = ""
        }
        
        unreadCountLabel.isHidden = (unreadCount == 0)
        unreadCountLabel.text = "\(unreadCount)"
    }
}
