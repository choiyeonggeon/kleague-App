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
        
        searchButton.setTitle("🔍", for: .normal)
        searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
        
        let topBar = UIStackView(arrangedSubviews: [teamFilterButton, UIView(), searchButton])
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
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
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
        let teams = ["전체", "서울", "서울E", "인천", "부천", "김포", "성남", "수원", "수원FC", "안양", "안산", "화성", "대전", "충북청주", "충남아산", "천안", "김천상무", "대구FC", "전북", "전남", "광주FC", "포항", "울산", "부산", "경남", "제주SK"]
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
    
    @objc private func refreshPosts() {
        fetchPosts()
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
    
    private func fetchPosts() {
        Firestore.firestore().collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                self?.refreshControl.endRefreshing()
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self?.posts = documents.compactMap { Post(from: $0) }
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
        filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        
        let post = filteredPosts[indexPath.row]
        cell.configure(with: post)
        
        cell.onReportButtonTapped = {
            let alelrt = UIAlertController(title: "신고", message: "이 게시글을 신고하시겠습니까?", preferredStyle: .alert)
            alelrt.addAction(UIAlertAction(title: "취소", style: .cancel))
            alelrt.addAction(UIAlertAction(title: "신고", style: .destructive, handler: { _ in
                print("신고된 게시글")
            }))
            self.present(alelrt, animated: true)
        }
        
        cell.onLikeButtonTapped = {
            let postRef = Firestore.firestore().collection("posts").document(post.id)
            postRef.updateData(["likes": post.likes + 1]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("좋아요 성공")
                    self.tableView.reloadData()
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = filteredPosts[indexPath.row]
        let detailVC = CommunityDetailVC(post: post)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
