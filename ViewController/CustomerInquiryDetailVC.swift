//
//  CustomerInquiryDetailVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/26/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CustomerInquiryDetailVC: UIViewController {
    
    private let inquiry: CustomerInquiry
    
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let answerLabel = UILabel()
    
    // 답변 입력용 UI (관리자용)
    private let answerTextView = UITextView()
    private let saveAnswerButton = UIButton(type: .system)
    
    init(inquiry: CustomerInquiry) {
        self.inquiry = inquiry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "문의 상세"
        setupInquiryUI()
        displayData()
        
        // 관리자용 답변 UI 표시 여부 결정
        checkAdminAndSetupAnswerUI()
    }
    
    private func setupInquiryUI() {
        titleLabel.font = .boldSystemFont(ofSize: 20)
        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 16)
        answerLabel.numberOfLines = 0
        answerLabel.textColor = .systemBlue
        answerLabel.font = .systemFont(ofSize: 16)
        
        view.addSubview(titleLabel)
        view.addSubview(contentLabel)
        view.addSubview(answerLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            answerLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12),
            answerLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            answerLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
    
    private func displayData() {
        titleLabel.text = "제목: \(inquiry.title)"
        contentLabel.text = "내용:\n\(inquiry.content)"
        
        if let answer = inquiry.answer, !answer.isEmpty {
            answerLabel.text = "답변:\n\(answer)"
        } else {
            answerLabel.text = "아직 답변이 등록되지 않았습니다."
        }
    }
    
    private func checkAdminAndSetupAnswerUI() {
        // 관리자 UID 체크 (예시로 하드코딩)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let adminUIDs = ["TPW61yAyNhZ3Ee3CvhO2xsdmGej1"] // 관리자 UID 목록
        if adminUIDs.contains(uid) {
            setupAnswerUI()
        }
    }
    
    private func setupAnswerUI() {
        answerTextView.layer.borderColor = UIColor.lightGray.cgColor
        answerTextView.layer.borderWidth = 1
        answerTextView.layer.cornerRadius = 8
        answerTextView.font = .systemFont(ofSize: 16)
        answerTextView.text = inquiry.answer ?? ""
        
        saveAnswerButton.setTitle("답변 저장", for: .normal)
        saveAnswerButton.addTarget(self, action: #selector(saveAnswerTapped), for: .touchUpInside)
        
        view.addSubview(answerTextView)
        view.addSubview(saveAnswerButton)
        
        answerTextView.translatesAutoresizingMaskIntoConstraints = false
        saveAnswerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            answerTextView.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 20),
            answerTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            answerTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            answerTextView.heightAnchor.constraint(equalToConstant: 150),
            
            saveAnswerButton.topAnchor.constraint(equalTo: answerTextView.bottomAnchor, constant: 12),
            saveAnswerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func saveAnswerTapped() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let adminUIDs = ["TPW61yAyNhZ3Ee3CvhO2xsdmGej1"]
        guard adminUIDs.contains(uid) else {
            showAlert(message: "관리자만 답변을 저장할 수 있습니다.")
            return
        }
        
        let newAnswer = answerTextView.text ?? ""
        if newAnswer.isEmpty {
            showAlert(message: "답변 내용을 입력해주세요.")
            return
        }
        
        let inquiryRef = Firestore.firestore()
            .collection("users")
            .document(uid) // 여기는 작성자 uid가 아니라 문의 작성자 uid 여야 함. 아래 설명 참고
            .collection("customerInquiries")
            .document(inquiry.id)
        
        inquiryRef.updateData([
            "answer": newAnswer,
            "answeredAt": Timestamp(date: Date())
        ]) { [weak self] error in
            if let error = error {
                self?.showAlert(message: "답변 저장 실패: \(error.localizedDescription)")
            } else {
                self?.showAlert(message: "답변이 저장되었습니다.") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
}
