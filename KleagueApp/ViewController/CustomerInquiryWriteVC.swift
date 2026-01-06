//
//  CustomerInquiryWriteVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/26/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CustomerInquiryWriteVC: UIViewController {
    
    private let titleField = UITextField()
    private let contentTextView = UITextView()
    private let submitButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "문의 작성"
        setupServiceUI()
    }
    
    private func setupServiceUI() {
        titleField.placeholder = "제목"
        titleField.borderStyle = .roundedRect
        
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 8
        contentTextView.font = .systemFont(ofSize: 17)
        
        submitButton.setTitle("제출", for: .normal)
        submitButton.addTarget(self, action: #selector(handleSubmitButton), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [titleField, contentTextView, submitButton])
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            contentTextView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func handleSubmitButton() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let title = titleField.text, !title.isEmpty,
        let content = contentTextView.text, !content.isEmpty else { return }
        
        let data: [String: Any] = [
            "authorUid": uid,
            "title": title,
            "content": content,
            "createdAt": Timestamp(date: Date())
        ]
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("customerInquiries")
            .addDocument(data: data) { error in
                if let error = error {
                    print("문의 등록 실패:", error.localizedDescription)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
    }
}
