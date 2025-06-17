//
//  CommunityDetailVC.swift
//  gugchugyeojido
//
//  Created by 최영건 on 6/17/25.
//

import Foundation
import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

struct Comment {
    let author: String
    let text: String
}

class CommunityDetailVC: UIViewController {
    
    var post: Post!
    
    private var comments: [Comment] = [] // ✅ 오타 수정
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let authorLabel = UILabel()
    private let likeButton = UIButton()
    private let dislikeButton = UIButton()
    private let commentField = UITextField()
    private let commentButton = UIButton(type: .system)
    private let commentTableView = UITableView()
    
    private let currentUserName = "현재사용자"
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDetailUI()
        loadComments()
    }
    
    private func setupDetailUI() {
        title = "글 상세"
        
        titleLabel.text = post.title
        titleLabel.font = .boldSystemFont(ofSize: 24)
        
        contentLabel.text = post.preview
        contentLabel.numberOfLines = 0
        
        authorLabel.text = "글쓴이: \(post.author)"
        authorLabel.font = .systemFont(ofSize: 14)
        authorLabel.textColor = .gray
        
        likeButton.setTitle("❤️ \(post.likes)", for: .normal)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        
        dislikeButton.setTitle("👎 \(post.dislikes)", for: .normal)
        dislikeButton.setTitleColor(.systemRed, for: .normal)
        dislikeButton.addTarget(self, action: #selector(didTapDislike), for: .touchUpInside)
        
        commentField.placeholder = "댓글을 입력하세요!"
        commentField.borderStyle = .roundedRect
        
        commentButton.setTitle("작성", for: .normal)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        
        commentTableView.dataSource = self
        commentTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
        
        [titleLabel, contentLabel, authorLabel, likeButton, dislikeButton, commentField, commentButton, commentTableView].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        likeButton.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(16)
        }
        
        dislikeButton.snp.makeConstraints {
            $0.centerY.equalTo(likeButton)
            $0.leading.equalTo(likeButton.snp.trailing).offset(20)
        }
        
        commentField.snp.makeConstraints {
            $0.top.equalTo(likeButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(commentButton.snp.leading).offset(-8)
            $0.height.equalTo(40)
        }
        
        commentButton.snp.makeConstraints {
            $0.centerY.equalTo(commentField)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(60)
        }
        
        commentTableView.snp.makeConstraints {
            $0.top.equalTo(commentField.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc private func didTapLike() {
        let ref = Firestore.firestore().collection("posts").document(post.id)
        ref.updateData(["likes": FieldValue.increment(Int64(1))])
        post.likes += 1
        likeButton.setTitle("❤️ \(post.likes)", for: .normal)
    }
    
    @objc private func didTapDislike() {
        let ref = Firestore.firestore().collection("posts").document(post.id)
        ref.updateData(["dislikes": FieldValue.increment(Int64(1))]) { [weak self] error in
            if error == nil {
                self?.post.dislikes += 1
                self?.dislikeButton.setTitle("👎 \(self?.post.dislikes ?? 0)", for: .normal)
            }
        }
    }
    
    @objc private func didTapComment() {
        guard let text = commentField.text, !text.isEmpty else { return }
        
        let newComment = Comment(author: currentUserName, text: text)
        comments.append(newComment)
        commentField.text = ""
        commentTableView.reloadData()
        
        let postRef = Firestore.firestore().collection("posts").document(post.id)
        postRef.collection("comments").addDocument(data: [
            "author": newComment.author,
            "text": newComment.text,
            "createdAt": Timestamp()
        ])
        
        postRef.updateData(["commentsCount": FieldValue.increment(Int64(1))])
    }
    
    private func loadComments() {
        Firestore.firestore()
            .collection("posts").document(post.id)
            .collection("comments")
            .order(by: "createdAt", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let documents = snapshot?.documents {
                    self.comments = documents.compactMap { doc in
                        let data = doc.data()
                        guard let author = data["author"] as? String,
                              let text = data["text"] as? String else { return nil }
                        return Comment(author: author, text: text)
                    }
                    self.commentTableView.reloadData()
                }
            }
    }
}

extension CommunityDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        let comment = comments[indexPath.row]
        cell.textLabel?.text = "\(comment.author): \(comment.text)"
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
