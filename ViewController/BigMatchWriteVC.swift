//
//  BigMatchWriteVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/27/25.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseAuth

class BigMatchWriteVC: UIViewController {
    
    private let leagueTextField = UITextField()
    private let matchTextField = UITextField()
    private let stadiumTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "빅매치 작성"
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        [leagueTextField, matchTextField, stadiumTextField].forEach {
            $0.borderStyle = .roundedRect
            view.addSubview($0)
        }
        
        leagueTextField.placeholder = "리그 (예: K리그1)"
        matchTextField.placeholder = "매치 (예: 서울 : 포항)"
        stadiumTextField.placeholder = "경기장 (예: 서울월드컵경기장)"
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = Locale(identifier: "ko_KR")
        view.addSubview(datePicker)
        
        saveButton.setTitle("작성하기", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        
        leagueTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        matchTextField.snp.makeConstraints {
            $0.top.equalTo(leagueTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(leagueTextField)
        }
        stadiumTextField.snp.makeConstraints {
            $0.top.equalTo(matchTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(leagueTextField)
        }
        datePicker.snp.makeConstraints {
            $0.top.equalTo(stadiumTextField.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(leagueTextField)
        }
        saveButton.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc private func saveTapped() {
        guard let uid = Auth.auth().currentUser?.uid,
              ["TPW61yAyNhZ3Ee3CvhO2xsdmGej1"].contains(uid) else {
            showAlert("권한이 없습니다.")
            return
        }
        
        guard let league = leagueTextField.text, !league.isEmpty,
              let match = matchTextField.text, !match.isEmpty,
              let stadium = stadiumTextField.text, !stadium.isEmpty else {
            showAlert("모든 항목을 입력해주세요.")
            return
        }
        
        let data: [String: Any] = [
            "league": league,
            "match": match,
            "stadium": stadium,
            "datetime": Timestamp(date: datePicker.date),
            "createdAt": Timestamp(date: Date())
        ]
        
        Firestore.firestore().collection("bigmatches").addDocument(data: data) { [weak self] error in
            if let error = error {
                self?.showAlert("저장 실패: \(error.localizedDescription)")
            } else {
                self?.showAlert("빅매치가 등록되었습니다.") {
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
