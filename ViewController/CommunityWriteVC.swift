//
//  CommunityWriteVC.swift
//  gugchugyeojido
//
//  Created by 최영건 on 6/16/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class CommunityWriteVC: UIViewController {
    
    private let titleField = UITextField()
    private let contentTextView = UITextView()
    private let teamPicker = UIPickerView()
    private let submitButton = UIButton(type: .system)
    
    private let teams = ["전체", "서울", "서울E", "인천", "부천", "김포", "성남", "수원", "수원FC", "안양", "안산", "화성","대전", "충북청주","충남아산", "천안", "김천상무", "대구FC", "전북", "전남", "광주FC", "포항", "울산", "부산", "경남", "제주SK"]
    
    private var selectedTeam: String? = "전체"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        teamPicker.dataSource = self
        teamPicker.delegate = self
        setupWriteUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupWriteUI() {
        title = "글쓰기"
        
        titleField.placeholder = "제목을 입력하세요"
        titleField.borderStyle = .roundedRect
        
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 8
        
        submitButton.setTitle("등록하기", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        
        [titleField, contentTextView, teamPicker, submitButton].forEach {
            view.addSubview($0)
        }
        
        titleField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        teamPicker.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        submitButton.snp.makeConstraints {
            $0.top.equalTo(teamPicker.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(44)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func didTapSubmit() {
        guard
            let title = titleField.text, !title.isEmpty,
            let content = contentTextView.text, !content.isEmpty,
            let team = selectedTeam,
            let user = Auth.auth().currentUser
        else {
            showAlert(message: "모든 항목을 입력해주세요.")
            return
        }
        
        let postData: [String: Any] = [
            "title": title,
            "content": content,
            "teamName": team,
            "likes": 0,
            "dislikes": 0,
            "commentsCount": 0,
            "author": user.email ?? "알 수 없음",
            "createdAt": Timestamp()
        ]
        
        Firestore.firestore().collection("posts").addDocument(data: postData) { error in
            if let error = error {
                self.showAlert(message: "글 등록 실패: \(error.localizedDescription)")
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDataSource & Delegate
extension CommunityWriteVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teams.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teams[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTeam = teams[row]
    }
}
