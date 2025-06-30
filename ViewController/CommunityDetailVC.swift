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
    let authorUid: String
    var text: String
    let createdAt: Date
}

class CommunityDetailVC: UIViewController {
    
    var post: Post!
    private var comments: [Comment] = []
    private var currentUserNickname: String?
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let authorLabel = UILabel()
    private var likeButton = UIButton()
    private var dislikeButton = UIButton()
    private let commentField = UITextField()
    private let commentButton = UIButton(type: .system)
    private let commentTableView = UITableView()
    
    private let editButton = UIButton(type: .system)
    private let deletButton = UIButton(type: .system)
    
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
        fetchLatestPostInfo()
        fetchCurrentUserNickname()
        
        if Auth.auth().currentUser?.uid != post.authorUid {
            editButton.isHidden = true
            deletButton.isHidden = true
        }
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
        
        likeButton.setTitle("👍 \(post.likes)", for: .normal)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        
        dislikeButton.setTitle("👎 \(post.dislikes)", for: .normal)
        dislikeButton.setTitleColor(.systemRed, for: .normal)
        dislikeButton.addTarget(self, action: #selector(didTapDislike), for: .touchUpInside)
        
        commentField.placeholder = "댓글을 입력하세요!"
        commentField.borderStyle = .roundedRect
        
        commentButton.setTitle("작성", for: .normal)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        
        editButton.setTitle("수정", for: .normal)
        editButton.setTitleColor(.systemBlue, for: .normal)
        editButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        
        deletButton.setTitle("삭제", for: .normal)
        deletButton.setTitleColor(.systemRed, for: .normal)
        deletButton.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        
        view.addSubview(editButton)
        view.addSubview(deletButton)
        
        commentTableView.dataSource = self
        commentTableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        [titleLabel, contentLabel, authorLabel, likeButton, dislikeButton, commentField, commentButton, commentTableView, editButton, deletButton].forEach {
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
        
        editButton.snp.remakeConstraints {
            $0.trailing.equalTo(deletButton.snp.leading).offset(-8)
            $0.centerY.equalTo(dislikeButton)
            $0.width.equalTo(60)
            $0.height.equalTo(30)
        }
        
        deletButton.snp.remakeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(dislikeButton)
            $0.width.equalTo(60)
            $0.height.equalTo(30)
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
    
    private func fetchLatestPostInfo() {
        let ref = Firestore.firestore().collection("posts").document(post.id)
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data() else { return }
            
            let latestLikes = data["likes"] as? Int ?? 0
            let latestDislikes = data["dislikes"] as? Int ?? 0
            
            self.post.likes = latestLikes
            self.post.dislikes = latestDislikes
            
            self.likeButton.setTitle("👍 \(latestLikes)", for: .normal)
            self.dislikeButton.setTitle("👎 \(latestDislikes)", for: .normal)
        }
    }
    
    private func fetchCurrentUserNickname() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let nickname = data["nickname"] as? String {
                self.currentUserNickname = nickname
            } else {
                self.currentUserNickname = "익명"
            }
        }
    }
    
    @objc private func didTapLike() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore().collection("posts").document(post.id)
        
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data() else { return }
            var likedUserIds = data["likedUserIds"] as? [String] ?? []
            
            if likedUserIds.contains(uid) {
                let alert = UIAlertController(title: "알림", message: "이미 좋아요를 누르셨습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            likedUserIds.append(uid)
            ref.updateData([
                "likes": FieldValue.increment(Int64(1)),
                "likedUserIds": likedUserIds
            ]) { error in
                if error == nil {
                    self.post.likes += 1
                    self.likeButton.setTitle("👍 \(self.post.likes)", for: .normal)
                }
            }
        }
    }
    
    @objc private func didTapDislike() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore().collection("posts").document(post.id)
        
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data() else { return }
            var dislikedUserIds = data["dislikedUserIds"] as? [String] ?? []
            
            if dislikedUserIds.contains(uid) {
                let alert = UIAlertController(title: "알림", message: "이미 싫어요를 누르셨습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            dislikedUserIds.append(uid)
            ref.updateData([
                "dislikes": FieldValue.increment(Int64(1)),
                "dislikedUserIds": dislikedUserIds
            ]) { error in
                if error == nil {
                    self.post.dislikes += 1
                    self.dislikeButton.setTitle("👎 \(self.post.dislikes)", for: .normal)
                }
            }
        }
    }
    
    @objc private func didTapDelete() {
        let alert = UIAlertController(title: "글 삭제", message: "이 글을 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            Firestore.firestore().collection("posts").document(self.post.id).delete { error in
                if let error = error {
                    print("삭제 실패 \(error.localizedDescription)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }))
        present(alert, animated: true)
    }
    
    @objc private func didTapEdit() {
        let writeVC = CommunityWriteVC()
        writeVC.editingPost = post
        navigationController?.pushViewController(writeVC, animated: true)
    }
    
    @objc private func didTapComment() {
        guard Auth.auth().currentUser != nil else {
            let alert = UIAlertController(title: "로그인 필요", message: "댓글을 작성하려면 로그인해야 합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard let text = commentField.text, !text.isEmpty else { return }
        let authorName = self.currentUserNickname ?? self.currentUserName
        
        let newComment = Comment(
            id: UUID().uuidString,
            postId: post.id,
            author: authorName,
            authorUid: Auth.auth().currentUser?.uid ?? "",
            text: text,
            createdAt: Date(),
        )
        
        comments.append(newComment)
        commentField.text = ""
        commentTableView.reloadData()
        
        let postRef = Firestore.firestore().collection("posts").document(post.id)
        postRef.collection("comments").addDocument(data: [
            "author": authorName,
            "authorUid": Auth.auth().currentUser?.uid ?? "",
            "text": text,
            "createdAt": Timestamp(date: newComment.createdAt)
        ])
        
        postRef.updateData(["commentsCount": FieldValue.increment(Int64(1))])
    }
    
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
                        let authorUid = data["authorUid"] as? String ?? ""
                        
                        return Comment(
                            id: doc.documentID,
                            postId: self.post.id,
                            author: author,
                            authorUid: authorUid,
                            text: text,
                            createdAt: timestamp.dateValue()
                        )
                    }
                    self.commentTableView.reloadData()
                }
            }
    }
    
    func isCurrentUserAdmin() -> Bool {
        let adminUids = ["TPW61yAyNhZ3Ee3CvhO2xsdmGej1", "관리자UID2"] // 관리자 UID 배열에 맞게 수정하세요
        if let uid = Auth.auth().currentUser?.uid {
            return adminUids.contains(uid)
        }
        return false
    }
    
    func editComment(_ comment: Comment) {
        let alert = UIAlertController(title: "댓글 수정", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = comment.text
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "저장", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            guard let newText = alert.textFields?.first?.text, !newText.isEmpty else { return }
            
            let commentRef = Firestore.firestore()
                .collection("posts")
                .document(comment.postId)
                .collection("comments")
                .document(comment.id)
            
            commentRef.updateData(["text": newText]) { error in
                if let error = error {
                    print("댓글 수정 실패: \(error.localizedDescription)")
                } else {
                    if let index = self.comments.firstIndex(where: { $0.id == comment.id }) {
                        self.comments[index].text = newText
                        self.commentTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
    
    func deleteComment(_ comment: Comment) {
        let alert = UIAlertController(title: "댓글 삭제", message: "이 댓글을 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
            let commentRef = Firestore.firestore()
                .collection("posts")
                .document(comment.postId)
                .collection("comments")
                .document(comment.id)
            
            commentRef.delete { error in
                if let error = error {
                    print("댓글 삭제 실패: \(error.localizedDescription)")
                } else {
                    if let index = self.comments.firstIndex(where: { $0.id == comment.id }) {
                        self.comments.remove(at: index)
                        self.commentTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                    
                    let postRef = Firestore.firestore()
                        .collection("posts")
                        .document(comment.postId)
                    postRef.updateData(["commentsCount": FieldValue.increment(Int64(-1))])
                }
            }
        }))
        present(alert, animated: true)
    }
    
}

extension CommunityDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        let comment = comments[indexPath.row]
        
        let currentUid = Auth.auth().currentUser?.uid
        let isAdminOrAuthor = (currentUid == comment.authorUid) || isCurrentUserAdmin()
        
        cell.configure(
            author: comment.author,
            text: comment.text,
            time: timeAgoString(from: comment.createdAt),
            showEditDelete: isAdminOrAuthor
        )
        
        cell.onReportTapped = { [weak self] in
            self?.reportComment(comment)
        }
        cell.onEditTapped = { [weak self] in
            self?.editComment(comment)
        }
        cell.onDeleteTapped = { [weak self] in
            self?.deleteComment(comment)
        }
        
        return cell
    }
}

extension CommunityDetailVC {
    func reportPost() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let reportQuery = Firestore.firestore()
            .collection("reports")
            .whereField("postId", isEqualTo: post.id)
            .whereField("reportedByUid", isEqualTo: uid)
        
        reportQuery.getDocuments { snapshot, error in
            if let error = error {
                print("게시글 신고 중복 검사 실패: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                let alert = UIAlertController(
                    title: "이미 신고함",
                    message: "이 게시글은 이미 신고하셨습니다.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            let reportData: [String: Any] = [
                "postId": self.post.id,
                "reportedBy": self.currentUserName,
                "reportedByUid": uid,
                "reportType": "post",
                "reportedAt": Timestamp(date: Date())
            ]
            
            Firestore.firestore().collection("reports").addDocument(data: reportData) { error in
                if let error = error {
                    print("게시글 신고 저장 실패: \(error.localizedDescription)")
                } else {
                    let alert = UIAlertController(
                        title: "신고 완료",
                        message: "신고가 정상적으로 접수되었습니다.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
        
    }
}

extension CommunityDetailVC {
    func reportComment(_ comment: Comment) {
        guard let uid = Auth.auth().currentUser?.uid else {
            let alert = UIAlertController(title: "로그인 필요", message: "댓글 신고는 로그인 후 이용 가능합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let reportQuery = Firestore.firestore()
            .collection("commentReports")
            .whereField("commentId", isEqualTo: comment.id)
            .whereField("reportedByUid", isEqualTo: uid)
        
        reportQuery.getDocuments { snapshot, error in
            if let error = error {
                print("댓글 신고 중복 검사 실패: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                // 이미 신고한 댓글인 경우
                let alert = UIAlertController(title: "이미 신고함", message: "이 댓글은 이미 신고하셨습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            let reportData: [String: Any] = [
                "commentId": comment.id,
                "postId": comment.postId,
                "reportedBy": self.currentUserName,
                "reportedByUid": uid,
                "reportedAt": Timestamp(date: Date())
            ]
            
            Firestore.firestore().collection("commentReports").addDocument(data: reportData) { error in
                if let error = error {
                    print("댓글 신고 실패: \(error.localizedDescription)")
                    return
                }
                
                let postRef = Firestore.firestore().collection("posts").document(comment.postId)
                postRef.updateData(["reportCount": FieldValue.increment(Int64(1))]) { error in
                    if let error = error {
                        print("신고 횟수 증가 실패: \(error.localizedDescription)")
                        return
                    }
                    
                    postRef.getDocument { snapshot, error in
                        if let data = snapshot?.data(),
                           let reportCount = data["reportCount"] as? Int,
                           reportCount >= 5 {
                            
                            let userRef = Firestore.firestore().collection("users").document(comment.authorUid)
                            let suspendedUntil = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                            
                            userRef.updateData([
                                "isSuspended": true,
                                "suspendedUntil": Timestamp(date: suspendedUntil)
                            ]) { error in
                                if let error = error {
                                    print("유저 정지 실패: \(error.localizedDescription)")
                                } else {
                                    print("유저가 7일간 정지되었습니다.")
                                }
                            }
                        }
                    }
                }
                
                let successAlert = UIAlertController(title: "신고 완료", message: "댓글 신고가 접수되었습니다.", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(successAlert, animated: true)
            }
        }
    }
}

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
