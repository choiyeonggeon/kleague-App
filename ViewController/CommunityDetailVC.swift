//
//  CommunityDetailVC.swift
//  gugchugyeojido
//
//  Created by 최영건 on 6/17/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

struct Comment {
    let id: String
    let postId: String
    let author: String
    let text: String
    let createdAt: Date
}

class CommunityDetailVC: UIViewController {
    
    var post: Post!
    private var comments: [Comment] = []
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let authorLabel = UILabel()
    private let likeButton = UIButton()
    private let dislikeButton = UIButton()
    private let commentField = UITextField()
    private let commentButton = UIButton(type: .system)
    private let commentTableView = UITableView()
    
    private var currentUserName: String {
        Auth.auth().currentUser?.email ?? "익명"
    }
    
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
        commentTableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
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

        let newComment = Comment(
            id: UUID().uuidString,
            postId: post.id,
            author: currentUserName,
            text: text,
            createdAt: Date()
        )
        
        comments.append(newComment)
        commentField.text = ""
        commentTableView.reloadData()
        
        let postRef = Firestore.firestore().collection("posts").document(post.id)
        postRef.collection("comments").addDocument(data: [
            "author": newComment.author,
            "text": newComment.text,
            "createdAt": Timestamp(date: newComment.createdAt)
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
                              let text = data["text"] as? String,
                              let timestamp = data["createdAt"] as? Timestamp else { return nil }
                        return Comment(
                            id: doc.documentID,
                            postId: self.post.id,
                            author: author,
                            text: text,
                            createdAt: timestamp.dateValue()
                        )
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        let comment = comments[indexPath.row]
        cell.configure(author: comment.author, text: comment.text, time: timeAgoString(from: comment.createdAt))
        cell.onReportTapped = { [weak self] in
            self?.reportComment(comment)
        }
        return cell
    }
}

// 신고 처리 함수 추가
extension CommunityDetailVC {
    private func reportComment(_ comment: Comment) {
        let alert = UIAlertController(title: "댓글 신고", message: "이 댓글을 신고하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "신고", style: .destructive, handler: { _ in
            let reportData: [String: Any] = [
                "commentId": comment.id,
                "postId": comment.postId,
                "reportedBy": self.currentUserName,
                "reportedAt": Timestamp(date: Date())
            ]
            Firestore.firestore().collection("reports").addDocument(data: reportData) { error in
                if let error = error {
                    print("신고 실패: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        let successAlert = UIAlertController(title: "신고 완료", message: "신고가 접수되었습니다.", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(successAlert, animated: true)
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
}

// 날짜를 "몇 분 전" 같은 문자열로 변환하는 간단한 함수
extension CommunityDetailVC {
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "방금 전"
        } else if interval < 3600 {
            return "\(Int(interval / 60))분 전"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))시간 전"
        } else {
            return "\(Int(interval / 86400))일 전"
        }
    }
}
