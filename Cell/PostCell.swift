//
//  PostCell.swift
//  gugchugyeojido
//
//  Created by 최영건 on 6/16/25.
//

import UIKit
import SnapKit

class PostCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let previewLabel = UILabel()
    private let infoLabel = UILabel()
    private let authorLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupPostUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with post: Post) {
        titleLabel.text = "📌" + post.title
        previewLabel.text = post.preview
        infoLabel.text = "❤️ \(post.likes)   👍 댓글 \(post.comments)"
        authorLabel.text = "작성자: \(post.author)"
    }
    
    private func setupPostUI() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, previewLabel, infoLabel, authorLabel])
        stack.axis = .vertical
        stack.spacing = 8
        contentView.addSubview(stack)
        
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        previewLabel.font = .systemFont(ofSize: 14)
        previewLabel.textColor = .darkGray
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = .gray
        authorLabel.font = .systemFont(ofSize: 13)
        authorLabel.textColor = .lightGray
    }
}
