//
//  AdminInquiryAnswerVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AdminInquiryAnswerVC: UIViewController {
    private let inquiry: CustomerInquiry
    private let answerTextView = UITextView()
    private let submitButton = UIButton(type: .system)
    
    init(inquiry: CustomerInquiry) {
        self.inquiry = inquiry
        super.init(nibName: nil, bundle: nil)
        title = "답변 작성"
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        answerTextView.layer.borderColor = UIColor.lightGray.cgColor
        answerTextView.layer.borderWidth = 1
        answerTextView.layer.cornerRadius = 8
        answerTextView.font = .systemFont(ofSize: 17)
        answerTextView.text = inquiry.answer ?? ""
        
        submitButton.setTitle("답변 등록", for: .normal)
        submitButton.addTarget(self, action: #selector(submitAnswer), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [answerTextView, submitButton])
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            answerTextView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc private func submitAnswer() {
        guard let text = answerTextView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(message: "답변 내용을 입력하세요.")
            return
        }
        
        let authorUid = inquiry.authorUid
        let inquiryId = inquiry.id
        
        Firestore.firestore()
            .collection("users")
            .document(authorUid)
            .collection("customerInquiries")
            .document(inquiryId)
            .updateData([
                "answer": text,
                "answeredAt": Timestamp(date: Date())
            ]) { [weak self] error in
                if let error = error {
                    self?.showAlert(message: "답변 등록 실패: \(error.localizedDescription)")
                    return
                }
                self?.navigationController?.popViewController(animated: true)
            }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
