//
//  NoticeWriteVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class NoticeWriteVC: UIViewController {
    
    private let titleTextField = UITextField()
    private let contentTextView = UITextView()
    private let pinnedSwitch = UISwitch()
    private let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "공지 작성"
        setupUI()
    }
    
    private func setupUI() {
        let pinnedLabel = UILabel()
        pinnedLabel.text = "상단 고정"
        
        titleTextField.borderStyle = .roundedRect
        titleTextField.placeholder = "제목을 입력하세요"
        
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 8
        contentTextView.font = .systemFont(ofSize: 16)
        
        saveButton.setTitle("등록하기", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        [titleTextField, contentTextView, pinnedLabel, pinnedSwitch, saveButton].forEach {
            view.addSubview($0)
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(titleTextField)
            $0.height.equalTo(200)
        }
        
        pinnedLabel.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(16)
            $0.leading.equalTo(titleTextField)
        }
        
        pinnedSwitch.snp.makeConstraints {
            $0.centerY.equalTo(pinnedLabel)
            $0.leading.equalTo(pinnedLabel.snp.trailing).offset(10)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(pinnedLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc private func saveTapped() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let adminUIDs = ["TPW61yAyNhZ3Ee3CvhO2xsdmGej1"] // 관리자 UID만 허용
        guard adminUIDs.contains(uid) else {
            showAlert("권한이 없습니다.")
            return
        }
        
        guard let title = titleTextField.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty else {
            showAlert("제목과 내용을 모두 입력하세요.")
            return
        }
        
        let noticeData: [String: Any] = [
            "title": title,
            "content": content,
            "isPinned": pinnedSwitch.isOn,
            "date": Timestamp(date: Date())
        ]
        
        Firestore.firestore().collection("notices").addDocument(data: noticeData) { [weak self] error in
            if let error = error {
                self?.showAlert("공지 저장 실패: \(error.localizedDescription)")
            } else {
                self?.showAlert("등록되었습니다.") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
}
