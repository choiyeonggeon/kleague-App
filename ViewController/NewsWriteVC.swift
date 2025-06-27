//
//  NewsWriteVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class NewsWriteVC: UIViewController {
    
    private let titleTextField = UITextField()
    private let sourceTextField = UITextField()
    private let urlTextField = UITextField()
    private let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "뉴스 작성"
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        titleTextField.placeholder = "뉴스 제목"
        sourceTextField.placeholder = "출처"
        urlTextField.placeholder = "URL 링크"
        
        [titleTextField, sourceTextField, urlTextField].forEach {
            $0.borderStyle = .roundedRect
            view.addSubview($0)
        }
        
        saveButton.setTitle("작성하기", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        sourceTextField.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(titleTextField)
        }
        
        urlTextField.snp.makeConstraints {
            $0.top.equalTo(sourceTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(titleTextField)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(urlTextField.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc private func saveTapped() {
        guard let uid = Auth.auth().currentUser?.uid,
              ["TPW61yAyNhZ3Ee3CvhO2xsdmGej1"].contains(uid) else {
            showAlert("권한이 없습니다.")
            return
        }
        
        guard let title = titleTextField.text, !title.isEmpty,
              let source = sourceTextField.text, !source.isEmpty,
              let url = urlTextField.text, !url.isEmpty else {
            showAlert("모든 항목을 입력해주세요.")
            return
        }
        
        let data: [String: Any] = [
            "title": title,
            "source": source,
            "url": url,
            "date": Timestamp(date: Date())
        ]
        
        Firestore.firestore().collection("homeNews").addDocument(data: data) { [weak self] error in
            if let error = error {
                self?.showAlert("저장 실패: \(error.localizedDescription)")
            } else {
                self?.showAlert("뉴스가 등록되었습니다.") {
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
