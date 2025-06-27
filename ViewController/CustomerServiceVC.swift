//
//  CustomerService.swift
//  KleagueApp
//
//  Created by 최영건 on 6/12/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CustomerServiceVC: UIViewController {
    
    private var inquiries: [CustomerInquiry] = []
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "고객센터"
        
        setupNavigationBar()
        setupTableView()
        fetchInquiries()
        tableView.register(InquiryCell.self, forCellReuseIdentifier: InquiryCell.identifier) // 커스텀 셀 등록
    }
    
    private func setupNavigationBar() {
        let writeButton = UIBarButtonItem(title: "문의 작성",
                                          style: .plain,
                                          target: self,
                                          action: #selector(didTapWriteInquiry))
        navigationItem.rightBarButtonItem = writeButton
    }
    
    @objc private func didTapWriteInquiry() {
        let writeVC = CustomerInquiryWriteVC()
        navigationController?.pushViewController(writeVC, animated: true)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchInquiries() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("customerInquiries")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("문의 불러오기 실패: \(error.localizedDescription)")
                    return
                }
                self?.inquiries = snapshot?.documents.compactMap {
                    CustomerInquiry(from: $0, authorUid: uid)
                } ?? []
                self?.tableView.reloadData()
            }
    }
}

extension CustomerServiceVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        inquiries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let inquiry = inquiries[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InquiryCell.identifier, for: indexPath) as? InquiryCell else {
            return UITableViewCell()
        }
        cell.configure(with: inquiry)
        
        cell.authorLabel.text = "문의자: \(inquiry.authorUid)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let inquiry = inquiries[indexPath.row]
        let detailVC = CustomerInquiryDetailVC(inquiry: inquiry)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
