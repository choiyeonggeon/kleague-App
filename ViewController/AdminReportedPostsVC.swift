//
//  AdminReportedPostsVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/24/25.
//

import UIKit

class AdminReportedPostsVC: UIViewController {
    
    private var reportedPosts: [Post] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "신고 관리"
        view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AdminPostCell.self, forCellReuseIdentifier: "AdminPostCell")
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        loadReportedPosts()
    }
    
    private func loadReportedPosts() {
        FirebasePostService.shared.fetchReportedPosts { [weak self] posts in
            DispatchQueue.main.async {
                self?.reportedPosts = posts
                self?.tableView.reloadData()
            }
        }
    }
}

extension AdminReportedPostsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AdminPostCell", for: indexPath) as? AdminPostCell else {
            return UITableViewCell()
        }
        
        let post = reportedPosts[indexPath.row]
        cell.configure(with: post)
        
        cell.onDeleteTapped = { [weak self] in
            FirebasePostService.shared.deletePost(postID: post.id) { result in
                switch result {
                case .success():
                    DispatchQueue.main.async {
                        self?.reportedPosts.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                case .failure(let error):
                    print("삭제 실패: \(error.localizedDescription)")
                }
            }
        }
        
        cell.onEditTapped = { [weak self] in
            self?.showEditAlert(for: post, index: indexPath.row)
        }
        
        return cell
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
                        self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                case .failure(let error):
                    print("수정 실패: \(error.localizedDescription)")
                }
                
            }
        })
        present(alertController, animated: true)
    }
}
