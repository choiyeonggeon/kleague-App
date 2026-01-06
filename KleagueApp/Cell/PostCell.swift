//
//  PostCell.swift
//  KleagueApp
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PostCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let previewLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let commentCountLabel = UILabel()
    private let likeButton = UIButton(type: .system)
    let reportButton = UIButton(type: .system)
    let hideButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)
    
    var isAdmin = Auth.auth().currentUser?.uid == "TPW61yAyNhZ3Ee3CvhO2xsdmGej1"
    var onReportButtonTapped: (() -> Void)?
    var onLikeButtonTapped: (() -> Void)?
    var onHideButtonTapped: (() -> Void)?
    var onDeleteButtonTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        previewLabel.font = .systemFont(ofSize: 14)
        previewLabel.textColor = .darkGray
        previewLabel.numberOfLines = 2
        
        authorLabel.font = .systemFont(ofSize: 12)
        authorLabel.textColor = .gray
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        dateLabel.textAlignment = .right
        
        commentCountLabel.font = .systemFont(ofSize: 12)
        commentCountLabel.textColor = .gray
        
        likeButton.titleLabel?.font = .systemFont(ofSize: 12)
        likeButton.setContentHuggingPriority(.required, for: .horizontal)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        
        reportButton.setTitle("신고", for: .normal)
        reportButton.titleLabel?.font = .systemFont(ofSize: 12)
        reportButton.setContentHuggingPriority(.required, for: .horizontal)
        reportButton.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)
        
        hideButton.setTitle("숨김", for: .normal)
        hideButton.titleLabel?.font = .systemFont(ofSize: 12)
        hideButton.setTitleColor(.systemRed, for: .normal)
        hideButton.setContentHuggingPriority(.required, for: .horizontal)
        hideButton.addTarget(self, action: #selector(didTapHide), for: .touchUpInside)
        
        deleteButton.setTitle("삭제", for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 12)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.setContentHuggingPriority(.required, for: .horizontal)
        deleteButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        
        let topInfoStack = UIStackView(arrangedSubviews: [authorLabel, dateLabel])
        topInfoStack.axis = .horizontal
        topInfoStack.spacing = 10
        topInfoStack.distribution = .fillProportionally
        
        let bottomInfoStack = UIStackView(arrangedSubviews: [commentCountLabel, likeButton, UIView(), reportButton, hideButton, deleteButton])
        bottomInfoStack.axis = .horizontal
        bottomInfoStack.spacing = 10
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, previewLabel, topInfoStack, bottomInfoStack])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with post: Post) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        dateLabel.text = formatter.string(from: post.createdAt)
        
        if post.isHidden {
            titleLabel.text = "[숨김 처리된 게시글]"
            previewLabel.text = "관리자에 의해 숨김 처리되었습니다."
            contentView.alpha = 0.4
            likeButton.isHidden = true
            reportButton.isHidden = true
            hideButton.isHidden = true
            deleteButton.isHidden = true
        } else {
            titleLabel.text = post.title
            previewLabel.text = post.preview
            likeButton.setTitle("👍 \(post.likes)", for: .normal)
            authorLabel.text = "글쓴이: \(post.author)"
            commentCountLabel.text = "💬 \(post.commentsCount)"
            contentView.alpha = 1.0
            likeButton.isHidden = false
            reportButton.isHidden = false
            hideButton.isHidden = !isAdmin
            deleteButton.isHidden = !isAdmin
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.alpha = 1.0
        likeButton.isHidden = false
        reportButton.isHidden = false
        hideButton.isHidden = false
        deleteButton.isHidden = false
    }
    
    @objc private func didTapReport() {
        onReportButtonTapped?()
    }
    
    @objc private func didTapLike() {
        onLikeButtonTapped?()
    }
    
    @objc private func didTapHide() {
        onHideButtonTapped?()
    }
    
    @objc private func didTapDelete() {
        onDeleteButtonTapped?()
    }
}
