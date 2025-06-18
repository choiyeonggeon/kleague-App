//
//  CommentCell.swift
//  KleagueApp
//
//  Created by 최영건 on 6/18/25.
//

import UIKit
import SnapKit

class CommentCell: UITableViewCell {
    
    let authorLabel = UILabel()
    let commentLabel = UILabel()
    let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        authorLabel.font = .boldSystemFont(ofSize: 14)
        commentLabel.font = .systemFont(ofSize: 14)
        commentLabel.numberOfLines = 0
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .gray

        let stack = UIStackView(arrangedSubviews: [authorLabel, commentLabel, timeLabel])
        stack.axis = .vertical
        stack.spacing = 4

        contentView.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }
    }

    func configure(author: String, text: String, time: String) {
        authorLabel.text = author
        commentLabel.text = text
        timeLabel.text = time
    }
}
