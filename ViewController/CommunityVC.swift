//
//  CommunityVC.swift
//  KleagueApp
//
//  Created by 최영건 on 5/29/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class CommunityVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let writeButton = UIButton(type: .system)
    private let seachButton = UIButton(type: .system)
    private let teamFilterButton = UIButton(type: .system)
    private let reportButton = UIButton(type: .system)
    
    private var posts: [Post] = []
    private var filteredPosts: [Post] = []
    private var selectedTeam: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCommunityUI()
        fetchPosts()
        title = "커뮤니티"
    }
    
    private func setupCommunityUI() {
        titleLabel.text = "국축여지도"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "GmarketSansTTFBold", size: 30)
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        teamFilterButton.setTitle("팀 필터 ⌄", for: .normal)
        teamFilterButton.addTarget(self, action: #selector(didTapTeamFilter), for: .touchUpInside)
        
        seachButton.setTitle("🔍", for: .normal)
        seachButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        
        let topBar = UIStackView(arrangedSubviews: [teamFilterButton, UIView(), seachButton])
        topBar.axis = .horizontal
        topBar.spacing = 10
        topBar.distribution = .fill
        view.addSubview(topBar)
        
        topBar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
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
        let vc = CommunityWriteVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapTeamFilter() {
        let teams = ["전체", "서울", "서울E", "인천", "부천", "김포", "성남", "수원", "수원FC", "안양", "안산", "화성","대전", "충북청주","충남아산", "천안", "김천상무", "대구FC", "전북", "전남", "광주FC", "포항", "울산", "부산", "경남", "제주SK"]
        let alert = UIAlertController(title: "팀 선택", message: nil, preferredStyle: .actionSheet)
        for team in teams {
            alert.addAction(UIAlertAction(title: team, style: .default, handler: { _ in
                self.selectedTeam = team == "전체" ? nil : team
                self.applyFilter()
            }))
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapSearch() {
        let alert = UIAlertController(title: "검색", message: "제목을 입력해주세요!", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "검색", style: .default, handler: { _ in
            guard let keyword = alert.textFields?.first?.text else { return }
            self.filteredPosts = self.posts.filter {
                $0.title.contains(keyword) || $0.preview.contains(keyword)
            }
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showReportAlert(postId: String) {
        let alert = UIAlertController(title: "신고", message: "신고 사유를 입력해주세요.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "신고 사유"
        }
        
        let reportAction = UIAlertAction(title: "신고", style: .default) { _ in
            guard let reason = alert.textFields?.first?.text, !reason.isEmpty else { return }
            self.reportPost(postId: postId, reason: reason)
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(reportAction)
        
        present(alert, animated: true)
    }
    
    private func reportPost(postId: String, reason: String) {
        guard let user = Auth.auth().currentUser else {
            print("❌ 로그인된 사용자가 없습니다.")
            return
        }
        
        let db = Firestore.firestore()
        let reportRef = db.collection("reports").document("postReports").collection("items").document()
        
        let data: [String: Any] = [
            "postId": postId,
            "reportedBy": user.uid,
            "reason": reason,
            "createdAt": Timestamp(date: Date())
        ]
        
        reportRef.setData(data) { error in
            if let error = error {
                print("❌ 신고 작성 중 오류: \(error.localizedDescription)")
                return
            }
            print("✅ 신고 작성 성공")
            let alert = UIAlertController(title: "신고", message: "신고가 접수되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    private func fetchPosts() {
        Firestore.firestore().collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self?.posts = documents.compactMap { Post(from: $0) }  // document snapshot 전달
                self?.applyFilter()
            }
    }
    
    private func applyFilter() {
        if let team = selectedTeam {
            filteredPosts = posts.filter { $0.team == team }
        } else {
            filteredPosts = posts
        }
        tableView.reloadData()
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
        cell.onReportButtonTapped = { [weak self] in
            self?.showReportAlert(postId: post.id)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = filteredPosts[indexPath.row]
        let detailVC = CommunityDetailVC(post: post)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
