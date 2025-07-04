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
    var isHidden: Bool
    let createdAt: Date
}

class CommunityDetailVC: UIViewController {
    
    var post: Post!
    private var comments: [Comment] = []
    private var badWords: [String] = []
    private var blockedUserIds: [String] = []
    private var currentUserNickname: String?
    var isAdmin = Auth.auth().currentUser?.uid == "TPW61yAyNhZ3Ee3CvhO2xsdmGej1"
    var isAuthor: Bool = false
    
    var currentUserUid: String? {
        return Auth.auth().currentUser?.uid
    }
    
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
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupDetailUI()
        checkIfCurrentUserIsAdmin()
        
        // 1. 초기 상태: 버튼 모두 숨김
        //        editButton.isHidden = true
        //        deletButton.isHidden = true
        
        // 2. 사용자 정보 불러와서 UI 업데이트
        loadUserInfo()
        
        fetchBadWords { [weak self] words in
            guard let self = self else { return }
            self.badWords = words
            self.fetchBlockedUsers {
                self.loadComments()
            }
        }
        
        fetchBlockedUsers { [weak self] in
            guard let self = self else { return }
            
            if self.blockedUserIds.contains(self.post.authorUid) {
                self.showAlert(title: "차단된 사용자", message: "차단한 사용자의 게시글입니다.") {
                    self.navigationController?.popViewController(animated: true)
                }
                return
            }
            
            self.loadUserInfo()
            self.loadComments()
            self.fetchLatestPostInfo()
            self.fetchCurrentUserNickname()
        }
        
        if Auth.auth().currentUser?.uid != post.authorUid {
            editButton.isHidden = true
            deletButton.isHidden = true
        }
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        if let uid = Auth.auth().currentUser?.uid, uid != post.authorUid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis.circle"),
                style: .plain,
                target: self,
                action: #selector(didTapMoreButton)
            )
        }
        
        if let currentUid = Auth.auth().currentUser?.uid, currentUid != post.authorUid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(didTapMoreButton))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        editButton.isHidden = true
        deletButton.isHidden = true
        navigationItem.leftBarButtonItem = nil
        
        commentTableView.rowHeight = UITableView.automaticDimension
        commentTableView.estimatedRowHeight = 100
        
        if let currentUid = Auth.auth().currentUser?.uid, currentUid != post.authorUid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis.circle"),
                style: .plain,
                target: self,
                action: #selector(didTapMoreButton)
            )
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func checkIfCurrentUserIsAdmin() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { [weak self] snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            self?.isAdmin = (data["role"] as? String) == "admin"
        }
    }
    
    // MARK: - UI Setup
    
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
        
        commentTableView.dataSource = self
        commentTableView.delegate = self
        commentTableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        
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
    
    private func loadUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.editButton.isHidden = true
                self.deletButton.isHidden = true
                self.navigationItem.leftBarButtonItem = nil
            }
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            
            self.isAdmin = (data["role"] as? String) == "admin"
            
            DispatchQueue.main.async {
                let isAuthor = (uid == self.post.authorUid)
                
                // 작성자거나 관리자면 수정/삭제 버튼 보임
                if isAuthor || self.isAdmin {
                    self.editButton.isHidden = false
                    self.deletButton.isHidden = false
                } else {
                    self.editButton.isHidden = true
                    self.deletButton.isHidden = true
                }
                
                self.commentTableView.reloadData()
            }
        }
    }
    
    // MARK: - 댓글 불러오기 및 필터링
    
    private func loadComments() {
        let ref = Firestore.firestore()
            .collection("posts")
            .document(post.id)
            .collection("comments")
            .order(by: "createdAt", descending: false)
        ref.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("댓글 불러오기 실패: \(error.localizedDescription)")
                return
            }
            
            var fetchedComments: [Comment] = []
            snapshot?.documents.forEach { doc in
                let data = doc.data()
                guard
                    let author = data["author"] as? String,
                    let authorUid = data["authorUid"] as? String,
                    let text = data["text"] as? String,
                    let timestamp = data["createdAt"] as? Timestamp,
                    let isHidden = data["isHidden"] as? Bool,
                    isHidden == false
                else { return }
                
                // 차단된 유저 댓글 필터링
                if self.blockedUserIds.contains(authorUid) {
                    return
                }
                
                let comment = Comment(
                    id: doc.documentID,
                    postId: self.post.id,
                    author: author,
                    authorUid: authorUid,
                    text: text,
                    isHidden: false,
                    createdAt: timestamp.dateValue()
                )
                fetchedComments.append(comment)
            }
            
            self.comments = fetchedComments
            DispatchQueue.main.async {
                self.commentTableView.reloadData()
            }
        }
    }
    
    // MARK: - 차단 유저 불러오기
    
    private func fetchBlockedUsers(completion: @escaping () -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            blockedUserIds = []
            completion()
            return
        }
        Firestore.firestore()
            .collection("users")
            .document(currentUid)
            .collection("blockedUsers")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("차단 유저 불러오기 실패: \(error)")
                    self?.blockedUserIds = []
                    completion()
                    return
                }
                self?.blockedUserIds = snapshot?.documents.map { $0.documentID } ?? []
                completion()
            }
    }
    
    func blockUser(uid: String, completion: @escaping () -> Void = {}) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore()
            .collection("users")
            .document(currentUid)
            .collection("blockedUsers")
            .document(uid)
            .setData(["blockedAt": Timestamp(date: Date())]) { [weak self] error in
                if let error = error {
                    print("유저 차단 실패: \(error.localizedDescription)")
                } else {
                    print("유저 차단 성공")
                    self?.fetchBlockedUsers {
                        self?.loadComments()
                        completion()
                    }
                    self?.showAlert(title: "차단 완료", message: "해당 사용자의 댓글 또는 게시글이 숨겨집니다.")
                }
            }
    }
    
    func unblockUser(uid: String, completion: @escaping () -> Void = {}) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore()
            .collection("users")
            .document(currentUid)
            .collection("blockedUsers")
            .document(uid)
            .delete { [weak self] error in
                if let error = error {
                    print("차단 해제 실패: \(error.localizedDescription)")
                } else {
                    print("차단 해제 성공")
                    self?.fetchBlockedUsers {
                        self?.loadComments()
                        completion()
                    }
                    self?.showAlert(title: "차단 해제", message: "해당 사용자의 댓글이 다시 표시됩니다.")
                }
            }
    }
    
    // MARK: - 금지어 불러오기
    
    func fetchBadWords(completion: @escaping ([String]) -> Void) {
        Firestore.firestore().collection("badWords").getDocuments { snapshot, error in
            if let error = error {
                print("금지어 불러오기 실패:", error.localizedDescription)
                completion([])
                return
            }
            let words = snapshot?.documents.compactMap { $0.data()["word"] as? String } ?? []
            completion(words)
        }
    }
    
    func containsBadWord(_ text: String, badwords: [String]) -> Bool {
        let loweredText = text.lowercased()
        for word in badwords {
            if loweredText.contains(word.lowercased()) {
                return true
            }
        }
        return false
    }
    
    // MARK: - 댓글 작성
    
    @objc private func didTapComment() {
        guard Auth.auth().currentUser != nil else {
            let alert = UIAlertController(title: "로그인 필요", message: "댓글을 작성하려면 로그인해야 합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard let text = commentField.text, !text.isEmpty else {
            let alert = UIAlertController(title: "입력 오류", message: "모든 항목을 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        if containsBadWord(text, badwords: badWords) {
            let alert = UIAlertController(title: "금지어 포함", message: "댓글에 금지어가 포함되어 있습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let authorName = self.currentUserNickname ?? self.currentUserName
        
        let newComment = Comment(
            id: UUID().uuidString,
            postId: post.id,
            author: authorName,
            authorUid: Auth.auth().currentUser?.uid ?? "",
            text: text,
            isHidden: false,
            createdAt: Date()
        )
        
        comments.append(newComment)
        commentField.text = ""
        commentTableView.reloadData()
        
        let postRef = Firestore.firestore().collection("posts").document(post.id)
        postRef.collection("comments").addDocument(data: [
            "author": authorName,
            "authorUid": Auth.auth().currentUser?.uid ?? "",
            "text": text,
            "createdAt": Timestamp(date: newComment.createdAt),
            "isHidden": false,
            "reportCount": 0
        ]) { error in
            if let error = error {
                print("댓글 저장 실패: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.commentField.text = ""
                self.commentTableView.reloadData()
            }
            postRef.updateData(["commentsCount": FieldValue.increment(Int64(1))])
        }
    }
    
    // MARK: - 최신 게시글 좋아요/싫어요 정보 업데이트
    
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
    
    // MARK: - 유저 닉네임 불러오기
    
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
    
    // MARK: - 좋아요 / 싫어요 액션
    
    @objc private func didTapLike() {
        guard let uid = Auth.auth().currentUser?.uid else {
            let alert = UIAlertController(title: "로그인 필요", message: "좋아요를 누르려면 로그인해야 합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
            return
        }
        
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
        guard let uid = Auth.auth().currentUser?.uid else {
            let alert = UIAlertController(title: "로그인 필요", message: "싫어요를 누르려면 로그인해야 합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
            return
        }
        
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
    
    // MARK: - 글 수정 / 삭제
    
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - 신고
    
    @objc private func didTapReportPost() {
        guard Auth.auth().currentUser != nil else {
            let alert = UIAlertController(title: "로그인 필요", message: "신고하려면 로그인해야 합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(title: "신고 사유 선택", message: nil, preferredStyle: .actionSheet)
        let reasons = ["욕설 및 비방", "스팸", "음란물", "기타"]
        for reason in reasons {
            alert.addAction(UIAlertAction(title: reason, style: .default, handler: { _ in
                self.reportPost(reason: reason)
            }))
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            if let barButtonItem = self.navigationItem.rightBarButtonItem {
                popover.barButtonItem = barButtonItem
            } else {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(
                    x: self.view.bounds.midX,
                    y: self.view.bounds.midY,
                    width: 0,
                    height: 0)
            }
        }
        present(alert, animated: true)
    }
    
    // 신고 처리 실제 로직 (예시)
    func reportPost(reason: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let firestore = Firestore.firestore()
        
        // 중복 신고 방지
        firestore.collection("reports")
            .whereField("postId", isEqualTo: post.id)
            .whereField("reportedByUid", isEqualTo: currentUser.uid)
            .whereField("resolved", isEqualTo: false)
            .whereField("isHidden", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("신고 중복 검사 실패: \(error.localizedDescription)")
                    return
                }
                
                // 이미 신고한 경우
                if let documents = snapshot?.documents, !documents.isEmpty {
                    self.showAlert(title: "이미 신고함", message: "이미 이 게시글을 신고하셨습니다.")
                    return
                }
                
                // 신고 등록
                let reportData: [String: Any] = [
                    "postId": self.post.id,
                    "reportedUserId": self.post.authorUid,
                    "reportedByUid": currentUser.uid,
                    "reportedBy": currentUser.email ?? "익명",
                    "reason": reason,
                    "reportedAt": Timestamp(date: Date()),
                    "reportCount": 0,
                    "isHidden": false,
                    "resolved": false
                ]
                
                let reportRef = firestore.collection("reports").document()
                reportRef.setData(reportData) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.showAlert(title: "신고 실패", message: error.localizedDescription)
                        } else {
                            self.showAlert(title: "신고 완료", message: "신고가 접수되었습니다. 24시간 이내에 관리자에 의해 검토 후 조치될 예정입니다.")
                        }
                    }
                }
            }
    }
    
    func reportComment(comment: Comment) {
        guard Auth.auth().currentUser != nil else {
            let alert = UIAlertController(title: "로그인 필요", message: "신고하려면 로그인해야 합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(title: "댓글 신고 사유 선택", message: nil, preferredStyle: .actionSheet)
        let reasons = ["욕설 및 비방", "스팸", "음란물", "기타"]
        for reason in reasons {
            alert.addAction(UIAlertAction(title: reason, style: .default, handler: { _ in
                self.submitCommentReport(comment: comment, reason: reason)
            }))
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        present(alert, animated: true)
    }
    
    private func submitCommentReport(comment: Comment, reason: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let firestore = Firestore.firestore()
        
        // 중복 신고 검사
        firestore.collection("reports")
            .whereField("commentId", isEqualTo: comment.id)
            .whereField("reportedByUid", isEqualTo: currentUser.uid)
            .whereField("resolved", isEqualTo: false)
            .whereField("isHidden", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("댓글 신고 중복 검사 실패: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    self.showAlert(title: "이미 신고함", message: "이미 이 댓글을 신고하셨습니다.")
                    return
                }
                
                let reportData: [String: Any] = [
                    "commentId": comment.id,
                    "postId": comment.postId,
                    "reportedUserId": comment.authorUid,
                    "reportedByUid": currentUser.uid,
                    "reportedBy": currentUser.email ?? "익명",
                    "reason": reason,
                    "reportedAt": Timestamp(date: Date()),
                    "reportCount": 0,
                    "isHidden": false,
                    "resolved": false
                ]
                
                firestore.collection("reports").addDocument(data: reportData) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.showAlert(title: "신고 실패", message: error.localizedDescription)
                        } else {
                            self.showAlert(title: "신고 완료", message: "댓글 신고가 접수되었습니다. 24시간 이내에 검토 후 조치될 예정입니다.")
                        }
                    }
                }
            }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableView Delegate & DataSource

extension CommunityDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        
        let comment = comments[indexPath.row]
        let isBlocked = blockedUserIds.contains(comment.authorUid)
        
        cell.configure(
            with: comment,
            isBlocked: blockedUserIds.contains(comment.authorUid),
            isAdmin: isAdmin,
            isAuthor: comment.authorUid == Auth.auth().currentUser?.uid
        )
        
        // 차단 / 차단 해제 버튼 액션
        cell.blockAction = { [weak self] in
            guard let self = self else { return }
            if isBlocked {
                self.unblockUser(uid: comment.authorUid)
            } else {
                self.blockUser(uid: comment.authorUid)
            }
        }
        
        cell.reportAction = { [weak self] in
            guard let self = self else { return }
            self.reportComment(comment: comment)
        }
        
        cell.deleteAction = { [weak self] in
            guard let self = self else { return }
            
            // 🔐 삭제 권한 확인: 작성자 본인 또는 관리자
            guard self.isAdmin || comment.authorUid == self.currentUserUid else {
                self.showAlert(title: "권한 없음", message: "댓글을 삭제할 권한이 없습니다.")
                return
            }
            
            let commentRef = Firestore.firestore()
                .collection("posts")
                .document(self.post.id)
                .collection("comments")
                .document(comment.id)
            
            let postRef = Firestore.firestore().collection("posts").document(self.post.id)
            
            commentRef.delete { error in
                if let error = error {
                    print("댓글 삭제 실패: \(error.localizedDescription)")
                    return
                }
                
                // 댓글 수 감소 처리
                postRef.updateData([
                    "commentsCount": FieldValue.increment(Int64(-1))
                ]) { updateError in
                    if let updateError = updateError {
                        print("댓글 수 감소 실패: \(updateError.localizedDescription)")
                    }
                }
                
                self.loadComments()
            }
        }
        
        cell.hideAction = { [weak self] in
            guard let self = self else { return }
            Firestore.firestore()
                .collection("posts")
                .document(post.id)
                .collection("comments")
                .document(comment.id)
                .updateData(["isHidden": true]) { error in
                    if error == nil {
                        self.loadComments()
                    }
                }
        }
        
        cell.editAction = { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: "댓글 수정", message: nil, preferredStyle: .alert)
            alert.addTextField { $0.text = comment.text }
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "저장", style: .default, handler: { _ in
                guard let newText = alert.textFields?.first?.text, !newText.isEmpty else { return }
                
                if self.containsBadWord(newText, badwords: self.badWords) {
                    self.showAlert(title: "금지어 포함", message: "금지어가 포함된 댓글은 작성할 수 없습니다.")
                    return
                }
                
                Firestore.firestore()
                    .collection("posts")
                    .document(comment.postId)
                    .collection("comments")
                    .document(comment.id)
                    .updateData([
                        "text": newText
                    ]) { error in
                        if let error = error {
                            print("댓글 수정 실패: \(error.localizedDescription)")
                        } else {
                            self.loadComments()
                        }
                    }
            }))
            self.present(alert, animated: true)
        }
        
        return cell
    }
    
    @objc private func didTapHidePost() {
        let alert = UIAlertController(title: "게시글 숨김", message: "이 게시글을 사용자에게 숨기시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "숨김", style: .destructive, handler: { _ in
            Firestore.firestore().collection("posts").document(self.post.id).updateData(["isHidden": true]) { error in
                if let error = error {
                    self.showAlert(title: "실패", message: error.localizedDescription)
                } else {
                    self.showAlert(title: "완료", message: "게시글이 숨김 처리되었습니다.")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }))
        present(alert, animated: true)
    }
    
    @objc private func didTapMoreButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "신고하기", style: .destructive, handler: { _ in
            self.didTapReportPost()
        }))
        
        alert.addAction(UIAlertAction(title: "작성자 차단", style: .destructive, handler: { _ in
            self.blockUser(uid: self.post.authorUid) {
                self.showAlert(title: "차단 완료", message: "해당 사용자의 글이 숨겨집니다.")
                self.navigationController?.popViewController(animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        if let currentUid = Auth.auth().currentUser?.uid,
           currentUid != post.authorUid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "ellipsis.circle"),
                style: .plain,
                target: self,
                action: #selector(didTapMoreButton)
            )
        }
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = self.navigationItem.rightBarButtonItem
        }
        present(alert, animated: true)
    }
}
