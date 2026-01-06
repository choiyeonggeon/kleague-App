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
        fetchUnresolvedReports()
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
    
    private func suspendUser(userId: String, forDays days: Int) {
        let db = Firestore.firestore()
        let suspendedUntil = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        
        let data: [String: Any] = [
            "isSuspended": true,
            "suspendedUntil": Timestamp(date: suspendedUntil)
        ]
        
        db.collection("users").document(userId).updateData(data) { error in
            if let error = error {
                print("🔥 유저 정지 실패: \(error.localizedDescription)")
            } else {
                print("✅ 유저가 \(days)일 동안 정지되었습니다.")
            }
        }
    }
    
    private func deleteComment(postId: String, commentId: String) {
        let db = Firestore.firestore()
        db.collection("posts").document(postId).collection("comments").document(commentId)
            .delete { error in
                if let error = error {
                    print("❌ 댓글 삭제 실패: \(error.localizedDescription)")
                } else {
                    print("✅ 댓글 삭제 성공")
                }
            }
    }
    
    private func showCustomSuspensionAlert(userId: String) {
        let alert = UIAlertController(title: "정지 일 수 입력", message: "유저를 며칠 동안 정지시킬지 숫자로 입력하세요.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "예: 3"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "정지", style: .destructive, handler: { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
                  let days = Int(text),
                  days > 0 else {
                print("❌ 올바른 정지 일 수를 입력하세요.")
                return
            }
            self?.suspendUser(userId: userId, forDays: days)
        }))
        
        present(alert, animated: true)
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
        return 1 + reportedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeWriteCell.identifier, for: indexPath) as? NoticeWriteCell else {
                return UITableViewCell()
            }
            return cell
        } else {
            let identifier = "ReportedPostCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
            }
            
            let post = reportedPosts[indexPath.row - 1]
            let reportCountText = post.reportCount
            
            if let reportedDate = post.firstReportedAt {
                let hoursSinceReport = Int(Date().timeIntervalSince(reportedDate) / 3600)
                cell?.textLabel?.text = "🔴 \(post.title) - 신고 \(hoursSinceReport)시간 전"
            } else {
                cell?.textLabel?.text = "🔴 \(post.title) (\(reportCountText)회 신고)"
            }
            cell?.textLabel?.numberOfLines = 1
            
            let emailText = post.email ?? "이메일 없음"
            let contentSummary = post.content.count > 100 ? String(post.content.prefix(100)) + "..." : post.content
            
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
            alert.addAction(UIAlertAction(title: "커스텀 정지 (일 입력)", style: .default, handler: { [weak self] _ in
                self?.showCustomSuspensionAlert(userId: post.authorUid)
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
    
    private func fetchUnresolvedReports() {
        let db = Firestore.firestore()

        db.collection("reports")
            .whereField("reportType", isEqualTo: "post")
            .whereField("resolved", isEqualTo: false)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }

                let postIds = documents.compactMap { $0.data()["postId"] as? String }

                // 신고된 게시글 불러오기
                self.loadPosts(by: postIds)
            }
    }

    private func loadPosts(by ids: [String]) {
        let db = Firestore.firestore()
        var loadedPosts: [Post] = []
        let group = DispatchGroup()

        for id in ids {
            group.enter()
            db.collection("posts").document(id).getDocument { docSnapshot, error in
                defer { group.leave() }
                guard let doc = docSnapshot, doc.exists,
                      let post = Post(from: doc) else {
                    print("⚠️ 포스트 문서 없음 또는 변환 실패 - id: \(id)")
                    return
                }
                loadedPosts.append(post)
            }
        }

        group.notify(queue: .main) {
            self.reportedPosts = loadedPosts
            self.tableView.reloadData()
        }
    }
    
    func markReportResolved(for postId: String) {
        let db = Firestore.firestore()
        db.collection("reports")
            .whereField("postId", isEqualTo: postId)
            .whereField("resolved", isEqualTo: false)
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { doc in
                    doc.reference.updateData(["resolved": true])
                }
            }
    }

}
