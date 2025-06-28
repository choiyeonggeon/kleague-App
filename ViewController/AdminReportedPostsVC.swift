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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AdminReportedPostsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 공지 셀 1 + 신고 게시글 수
        return 1 + reportedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // 공지 셀
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeWriteCell.identifier, for: indexPath) as? NoticeWriteCell else {
                return UITableViewCell()
            }
            return cell
        } else {
            // 신고 게시글 셀 (기본 subtitle 스타일)
            let identifier = "ReportedPostCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
            }
            let post = reportedPosts[indexPath.row - 1]
            let reportCountText = post.reportCount ?? 0
            
            let emailText = post.author // 필요시 이메일 따로 로드
            let contentSummary = post.content.count > 100 ? String(post.content.prefix(100)) + "..." : post.content
            
            cell?.textLabel?.text = "🔴 \(post.title) (\(reportCountText)회 신고)"
            cell?.textLabel?.numberOfLines = 1
            
            cell?.detailTextLabel?.text = """
            작성자: \(post.author)
            이메일: \(emailText)
            내용: \(contentSummary)
            """
            cell?.detailTextLabel?.numberOfLines = 5
            cell?.selectionStyle = .none
            cell?.accessoryType = .detailButton
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 60 : 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let noticeWriteVC = NoticeWriteVC()
            navigationController?.pushViewController(noticeWriteVC, animated: true)
        } else {
            let post = reportedPosts[indexPath.row - 1]
            let alert = UIAlertController(title: "관리 옵션", message: "작성자: \(post.author)", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "활동 정지 (7일)", style: .destructive, handler: { [weak self] _ in
                self?.suspendUserFor7Days(userId: post.authorUid)
            }))
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
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
            }))
            alert.addAction(UIAlertAction(title: "수정", style: .default, handler: { [weak self] _ in
                self?.showEditAlert(for: post, index: indexPath.row - 1)
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            
            present(alert, animated: true)
        }
    }
}
