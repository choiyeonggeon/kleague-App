//
//  CommunityVC.swift
//  KleagueApp
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class CommunityVC: UIViewController {
    
    private var userTeam: String?
    
    private var isSuspendedUser = false
    private var isAdminUser = Auth.auth().currentUser?.uid == "TPW61yAyNhZ3Ee3CvhO2xsdmGej1"
    private var blockedUserIds: [String] = []
    private let popularButton = UIButton(type: .system)
    
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
        
        setupUI()
        fetchUserTeam()
        checkUserSuspendedStatus()
        checkIfAdminUser()
        checkSessionExpired()
        fetchBlockedUsers { [weak self] in
            self?.fetchPosts()
        }
        
        title = "커뮤니티"
    }
    
    private func checkSessionExpired() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        if currentUser.isSessionExpired() {
            let alert = UIAlertController(
                title: "세션 만료",
                message: "30일 동안 미접속으로 인해 로그아웃 되었습니다. 다시 로그인해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
                do {
                    try Auth.auth().signOut()
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.window?.rootViewController = LoginVC()
                    }
                } catch {
                    print("로그아웃 실패: \(error.localizedDescription)")
                }
            })
            
            present(alert, animated: true)
        }
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
    
    private func fetchUserTeam() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let team = data["team"] as? String {
                self.userTeam = team
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
    
    private func setupUI() {
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
        
        popularButton.setTitle("🔥인기글", for: .normal)
        popularButton.addTarget(self, action: #selector(didTapPopular), for: .touchUpInside)
        
        // 상단 바 (팀 필터 + 검색)
        let topBar = UIStackView(arrangedSubviews: [teamFilterButton, popularButton, UIView(), searchButton])
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
        
        var teams = ["전체"]
        if let team = userTeam {
            teams.append(team)
        }
        
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
    
    @objc private func didTapPopular() {
        self.filteredPosts = self.posts.filter { $0.likes >= 10 }
        self.tableView.reloadData()
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
                
                // 블록된 유저 제외
                self.posts = allPosts.filter { !self.blockedUserIds.contains($0.authorUid) }
                
                // 필터 적용
                self.applyFilter()
            }
    }
    
    private func applyFilter() {
        filteredPosts = posts.filter { post in
            // 블록된 유저는 이미 제외됨
            if let team = selectedTeam {
                // 팀 필터 선택 시: 선택한 팀 글만 보여줌
                return post.team == team
            } else {
                // 전체 게시판: team 필드가 nil이거나 "전체"인 경우만 표시
                return post.team == nil || post.team == "전체"
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func reportUser(post: Post, reason: String) {
        guard let reporterUserId = Auth.auth().currentUser?.uid else { return }
        
        let firestore = Firestore.firestore()
        
        // 🔹 중복 신고 검사
        firestore.collection("reports")
            .whereField("reportedByUid", isEqualTo: reporterUserId)
            .whereField("postId", isEqualTo: post.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.showAlert(title: "오류", message: "신고 중복 검사 실패: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    self.showAlert(title: "이미 신고함", message: "이 게시글은 이미 신고하셨습니다.")
                    return
                }
                
                // 🔹 신고 등록 (batch 없이 단일 set)
                let reportData: [String: Any] = [
                    "postId": post.id,
                    "reportedUserId": post.authorUid,
                    "reportedByUid": reporterUserId,
                    "reportedBy": Auth.auth().currentUser?.email ?? "익명",
                    "reason": reason,
                    "reportedAt": Timestamp(date: Date()),
                    "isHidden": false,
                    "resolved": false,
                    "reportType": "post"
                ]
                
                firestore.collection("reports").document().setData(reportData) { error in
                    if let error = error {
                        self.showAlert(title: "신고 실패", message: error.localizedDescription)
                        return
                    }
                    
                    self.showAlert(title: "신고 완료", message: "신고가 접수되었습니다.")
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
