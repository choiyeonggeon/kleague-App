//
//  CommunityVC.swift
//  KleagueApp
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class CommunityVC: UIViewController {
    
    private var isSuspendedUser = false
    private var isAdminUser = Auth.auth().currentUser?.uid == "TPW61yAyNhZ3Ee3CvhO2xsdmGej1"
    private var blockedUserIds: [String] = []
    
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let writeButton = UIButton(type: .system)
    private let searchButton = UIButton(type: .system)
    private let teamFilterButton = UIButton(type: .system)
    private let refreshControl = UIRefreshControl()
    
    private var posts: [Post] = []
    private var filteredPosts: [Post] = []
    private var selectedTeam: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupCommunityUI()
        checkUserSuspendedStatus()
        checkIfAdminUser()
        
        fetchBlockedUsers { [weak self] in
            self?.fetchPosts()
        }
        
        title = "커뮤니티"
    }
    
    // 관리자 여부 확인
    private func checkIfAdminUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            isAdminUser = false
            return
        }
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let adminFlag = data["isAdmin"] as? Bool {
                self.isAdminUser = adminFlag
                DispatchQueue.main.async {
                    self.tableView.reloadData() // 버튼 표시 반영
                }
            }
        }
    }
    
    private func checkUserSuspendedStatus() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let isSuspended = data["isSuspended"] as? Bool {
                self.isSuspendedUser = isSuspended
                DispatchQueue.main.async {
                    self.writeButton.isEnabled = !isSuspended
                    self.writeButton.backgroundColor = isSuspended ? .lightGray : .systemBlue
                }
            }
        }
    }
    
    private func fetchBlockedUsers(completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            blockedUserIds = []
            completion()
            return
        }
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("blockedUsers")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("차단 유저 불러오기 실패: \(error.localizedDescription)")
                    self.blockedUserIds = []
                    completion()
                    return
                }
                self.blockedUserIds = snapshot?.documents.map { $0.documentID } ?? []
                completion()
            }
    }
    
    private func setupCommunityUI() {
        // 타이틀 레이블
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 팀 필터 버튼
        teamFilterButton.setTitle("팀 필터 ⌄", for: .normal)
        teamFilterButton.addTarget(self, action: #selector(didTapTeamFilter), for: .touchUpInside)
        
        // 검색 버튼
        searchButton.setTitle("🔍", for: .normal)
        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        
        // 상단 바 (팀 필터 + 검색)
        let topBar = UIStackView(arrangedSubviews: [teamFilterButton, UIView(), searchButton])
        topBar.axis = .horizontal
        topBar.spacing = 10
        topBar.distribution = .fill
        view.addSubview(topBar)
        
        topBar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        // 테이블뷰 셋업
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        // 글쓰기 버튼
        writeButton.setTitle("⊕", for: .normal)
        writeButton.titleLabel?.font = .systemFont(ofSize: 30)
        writeButton.backgroundColor = .systemBlue
        writeButton.setTitleColor(.white, for: .normal)
        writeButton.layer.cornerRadius = 30
        writeButton.addTarget(self, action: #selector(didTapWriteButton), for: .touchUpInside)
        
        view.addSubview(writeButton)
        writeButton.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    @objc private func didTapWriteButton() {
        guard let _ = Auth.auth().currentUser else {
            showAlert(title: "로그인 필요", message: "글쓰기를 위해 로그인해주세요.")
            return
        }
        
        if isSuspendedUser {
            showAlert(title: "활동 제한", message: "신고 누적으로 인해 글쓰기 권한이 제한되었습니다.")
            return
        }
        
        let vc = CommunityWriteVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapTeamFilter() {
        let teams = ["전체", "서울", "서울E", "인천", "부천", "김포", "성남", "수원", "수원FC", "안양", "안산", "화성", "대전", "충북청주", "충남아산", "천안", "김천상무", "대구FC", "전북", "전남", "광주FC", "포항", "울산", "부산", "경남", "제주SK"]
        let alert = UIAlertController(title: "팀 선택", message: nil, preferredStyle: .actionSheet)
        for team in teams {
            alert.addAction(UIAlertAction(title: team, style: .default, handler: { _ in
                self.selectedTeam = team == "전체" ? nil : team
                self.applyFilter()
            }))
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // ✅ iPad용 popover anchor 설정
        if let popover = alert.popoverPresentationController {
            popover.sourceView = teamFilterButton
            popover.sourceRect = teamFilterButton.bounds
            popover.permittedArrowDirections = .up
        }
        
        present(alert, animated: true)
        
    }
    
    @objc private func didTapSearch() {
        let alert = UIAlertController(title: "검색", message: "제목을 입력해주세요!", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "검색", style: .default, handler: { _ in
            guard let keyword = alert.textFields?.first?.text, !keyword.isEmpty else { return }
            self.filteredPosts = self.posts.filter {
                $0.title.localizedCaseInsensitiveContains(keyword) || $0.preview.localizedCaseInsensitiveContains(keyword)
            }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func refreshPosts() {
        fetchBlockedUsers { [weak self] in
            self?.fetchPosts()
        }
    }
    
    private func fetchPosts() {
        Firestore.firestore().collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
                guard let self = self,
                      let documents = snapshot?.documents,
                      error == nil else {
                    print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let allPosts = documents.compactMap { Post(from: $0) }
                self.posts = allPosts.filter { !self.blockedUserIds.contains($0.authorUid) }
                self.applyFilter()
            }
    }
    
    private func applyFilter() {
        if let team = selectedTeam {
            filteredPosts = posts.filter { $0.team == team }
        } else {
            filteredPosts = posts
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func reportUser(post: Post, reason: String) {
        guard let reporterUserId = Auth.auth().currentUser?.uid else { return }
        
        // 중복 신고 검사
        let reportQuery = Firestore.firestore()
            .collection("reports")
            .whereField("isHidden", isEqualTo: false)
            .whereField("resolved", isEqualTo: false)
            .whereField("reportedByUid", isEqualTo: reporterUserId)
            .whereField("postId", isEqualTo: post.id)
        
        reportQuery.getDocuments { snapshot, error in
            if let error = error {
                self.showAlert(title: "오류", message: "신고 중복 검사 실패: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                self.showAlert(title: "이미 신고함", message: "이 게시글은 이미 신고하셨습니다.")
                return
            }
            
            let reportData: [String: Any] = [
                "postId": post.id,
                "reportedUserId": post.authorUid,
                "reportedByUid": reporterUserId,
                "reportedBy": Auth.auth().currentUser?.email ?? "익명",
                "reason": reason,
                "reportedAt": Timestamp(date: Date()),
                "isHidden": false,
                "resolved": false,
                "reportCount": 0
            ]
            
            let firestore = Firestore.firestore()
            let batch = firestore.batch()
            
            // 신고 기록 추가
            let reportRef = firestore.collection("reports").document()
            batch.setData(reportData, forDocument: reportRef)
            
            // 게시글 신고 횟수 증가
            let postRef = firestore.collection("posts").document(post.id)
            batch.updateData(["reportCount": FieldValue.increment(Int64(1))], forDocument: postRef)
            
            // 신고당한 유저 신고 횟수 증가
            let userRef = firestore.collection("users").document(post.authorUid)
            batch.updateData(["reportCount": FieldValue.increment(Int64(1))], forDocument: userRef)
            
            // 커밋 후 추가 작업
            batch.commit { error in
                if let error = error {
                    self.showAlert(title: "신고 실패", message: error.localizedDescription)
                    return
                }
                
                // 신고 횟수 조회 후 정지 처리
                userRef.getDocument { docSnapshot, error in
                    if let data = docSnapshot?.data(),
                       let count = data["reportCount"] as? Int {
                        
                        if count >= 10 {
                            // 영구 정지
                            userRef.updateData([
                                "isSuspended": true,
                                "isSuspendedUntil": FieldValue.delete()
                            ])
                        } else if count >= 5 {
                            // 7일 정지
                            let suspensionUntil = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                            userRef.updateData([
                                "isSuspended": true,
                                "isSuspendedUntil": suspensionUntil != nil ? Timestamp(date: suspensionUntil!) : FieldValue.delete()
                            ])
                        }
                    }
                }
                
                self.showAlert(title: "신고 완료", message: "신고가 접수되었습니다. 24시간 이내에 관리자에 의해 검토 후 조치될 예정입니다.")
            }
        }
    }
    
    func hidePost(_ post: Post, hide: Bool) {
        let postRef = Firestore.firestore().collection("posts").document(post.id)
        postRef.updateData(["isHidden": hide]) { error in
            if let error = error {
                print("게시글 숨김 처리 실패: \(error.localizedDescription)")
            } else {
                print("게시글 숨김 처리 성공: \(hide)")
                self.fetchPosts()
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension CommunityVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        
        let post = filteredPosts[indexPath.row]
        cell.configure(with: post)
        
        // 신고 버튼 액션
        cell.onReportButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            guard Auth.auth().currentUser != nil else {
                self.showAlert(title: "로그인 필요", message: "신고하려면 로그인해주세요.")
                return
            }
            
            let alert = UIAlertController(title: "신고 사유 선택", message: nil, preferredStyle: .actionSheet)
            let reasons = ["욕설 및 비방", "스팸", "음란물", "기타"]
            for reason in reasons {
                alert.addAction(UIAlertAction(title: reason, style: .default, handler: { _ in
                    self.reportUser(post: post, reason: reason)
                }))
            }
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            
            if let popover = alert.popoverPresentationController {
                popover.sourceView = cell
                popover.sourceRect = cell.bounds
                popover.permittedArrowDirections = [.up, .down]
            }
            self.present(alert, animated: true)
        }
        
        // 좋아요 버튼 액션
        cell.onLikeButtonTapped = { [weak self] in
            guard let self = self else { return }
            let postRef = Firestore.firestore().collection("posts").document(post.id)
            postRef.updateData(["likes": post.likes + 1]) { error in
                if let error = error {
                    print("Error updating likes: \(error)")
                } else {
                    self.fetchPosts()
                }
            }
        }
        
        cell.onDeleteButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(title: "삭제 확인", message: "정말로 이 게시글을 삭제하시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                Firestore.firestore().collection("posts").document(post.id).delete { error in
                    if let error = error {
                        self.showAlert(title: "삭제 실패", message: error.localizedDescription)
                    } else {
                        self.fetchPosts()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            self.present(alert, animated: true)
        }
        
        // 숨김 버튼 액션
        cell.onHideButtonTapped = { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: "게시글 숨김", message: "이 게시글을 숨기시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "숨기기", style: .destructive, handler: { _ in
                self.hidePost(post, hide: true)
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            self.present(alert, animated: true)
        }
        
        // 관리자일 때만 숨김 버튼 보이기
        cell.hideButton.isHidden = !isAdminUser
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = filteredPosts[indexPath.row]
        let detailVC = CommunityDetailVC(post: post)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
