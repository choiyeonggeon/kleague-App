//
//  AdminReportedPostsVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/24/25.
//

import UIKit
import FirebaseFirestore

class AdminReportedPostsVC: UIViewController {
    
    private var reportedPosts: [Post] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "신고 관리"
        view.backgroundColor = .white
        
        setupTableView()
        loadReportedPosts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AdminPostCell.self, forCellReuseIdentifier: "AdminPostCell")
        tableView.register(NoticeWriteCell.self, forCellReuseIdentifier: NoticeWriteCell.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadReportedPosts() {
        FirebasePostService.shared.fetchReportedPosts { [weak self] posts in
            DispatchQueue.main.async {
                self?.reportedPosts = posts
                self?.tableView.reloadData()
            }
        }
    }
    
    private func suspendUserFor7Days(userId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let data: [String: Any] = [
            "isSuspended": true,
            "suspendedUntil": Timestamp(date: sevenDaysLater)
        ]
        
        userRef.updateData(data) { error in
            if let error = error {
                print("🔥 유저 정지 실패: \(error.localizedDescription)")
            } else {
                print("✅ 유저가 7일간 정지되었습니다.")
            }
        }
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AdminReportedPostsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 공지 작성 셀 1개 + 신고된 게시글 수
        return 1 + reportedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            // 공지 작성 셀
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeWriteCell.identifier, for: indexPath) as? NoticeWriteCell else {
                return UITableViewCell()
            }
            return cell
        } else {
            // 신고 게시글 셀
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdminPostCell", for: indexPath) as? AdminPostCell else {
                return UITableViewCell()
            }
            let post = reportedPosts[indexPath.row - 1]
            cell.configure(with: post)
            
            cell.onDeleteTapped = { [weak self] in
                FirebasePostService.shared.deletePost(postID: post.id) { result in
                    switch result {
                    case .success():
                        DispatchQueue.main.async {
                            self?.reportedPosts.remove(at: indexPath.row - 1)
                            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    case .failure(let error):
                        print("삭제 실패: \(error.localizedDescription)")
                    }
                }
            }
            
            cell.onEditTapped = { [weak self] in
                self?.showEditAlert(for: post, index: indexPath.row - 1)
            }
            
            // 7일 정지 버튼 액션 추가
            cell.onSuspendTapped = { [weak self] in
                let alert = UIAlertController(title: "정지", message: "이 유저를 7일간 정지할까요?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "정지", style: .destructive, handler: { _ in
                    self?.suspendUserFor7Days(userId: post.authorUid)
                }))
                self?.present(alert, animated: true)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        }
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let noticeWriteVC = NoticeWriteVC()
            navigationController?.pushViewController(noticeWriteVC, animated: true)
        }
    }
    
    private func showEditAlert(for post: Post, index: Int) {
        let alertController = UIAlertController(title: "수정", message: nil, preferredStyle: .alert)
        alertController.addTextField { tf in tf.text = post.title }
        alertController.addTextField { tf in tf.text = post.content }
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
        alertController.addAction(UIAlertAction(title: "수정", style: .default) { [weak self] _ in
            guard let newTitle = alertController.textFields?[0].text,
                  let newContent = alertController.textFields?[1].text else { return }
            
            FirebasePostService.shared.updatePost(postID: post.id, newTitle: newTitle, newContent: newContent) { result in
                switch result {
                case .success():
                    DispatchQueue.main.async {
                        self?.reportedPosts[index].title = newTitle
                        self?.reportedPosts[index].content = newContent
                        self?.tableView.reloadRows(at: [IndexPath(row: index + 1, section: 0)], with: .automatic)
                    }
                case .failure(let error):
                    print("수정 실패: \(error.localizedDescription)")
                }
            }
        })
        present(alertController, animated: true)
    }
}
