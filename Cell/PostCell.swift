//
//  PostCell.swift
//  KleagueApp
//

import UIKit

class PostCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let previewLabel = UILabel()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let commentCountLabel = UILabel()
    private let likeButton = UIButton(type: .system)
    let reportButton = UIButton(type: .system)

    var onReportButtonTapped: (() -> Void)?
    var onLikeButtonTapped: (() -> Void)?

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

        commentCountLabel.font = .systemFont(ofSize: 12)
        commentCountLabel.textColor = .gray

        likeButton.setTitle("👍 0", for: .normal)
        likeButton.titleLabel?.font = .systemFont(ofSize: 12)
        likeButton.setContentHuggingPriority(.required, for: .horizontal)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)

        reportButton.setTitle("신고", for: .normal)
        reportButton.titleLabel?.font = .systemFont(ofSize: 12)
        reportButton.setContentHuggingPriority(.required, for: .horizontal)
        reportButton.addTarget(self, action: #selector(didTapReport), for: .touchUpInside)

        let topInfoStack = UIStackView(arrangedSubviews: [authorLabel, dateLabel])
        topInfoStack.axis = .horizontal
        topInfoStack.spacing = 10
        topInfoStack.distribution = .fillProportionally

        let bottomInfoStack = UIStackView(arrangedSubviews: [commentCountLabel, likeButton, UIView(), reportButton])
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
        titleLabel.text = post.title
        previewLabel.text = post.preview
        authorLabel.text = "글쓴이: \(post.author)"
        commentCountLabel.text = "💬 \(post.commentsCount)"
        likeButton.setTitle("👍 \(post.likes)", for: .normal)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        dateLabel.text = formatter.string(from: post.createdAt)
    }

    @objc private func didTapReport() {
        print("신고 버튼 눌림")
        onReportButtonTapped?()
    }

    @objc private func didTapLike() {
        print("좋아요 버튼 눌림")
        onLikeButtonTapped?()
    }
}
