//
//  PersonalInformationVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/12/25.
//

import UIKit
import PDFKit
import FirebaseAuth
import FirebaseFirestore

class PersonalInformationVC: UIViewController {
    
    private let emailLabel = UILabel()
    private let phoneLabel = UILabel()
    private let logoutButton = UIButton()
    private let deleteButton = UIButton()
    private let resetPasswordButton = UIButton()
    private let privacyPolicyButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "개인정보"
        setupPsronll()
        loadUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAuthButtonTitle()
    }
    
    
    private func setupPsronll() {
        emailLabel.font = .systemFont(ofSize: 17, weight: .medium)
        phoneLabel.font = .systemFont(ofSize: 17, weight: .medium)
        
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.setTitleColor(.systemBlue, for: .normal)
        logoutButton.addTarget(self, action: #selector(TappedLogout), for: .touchUpInside)
        
        deleteButton.setTitle("회원탈퇴", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.addTarget(self, action: #selector(TappedDelet), for: .touchUpInside)
        
        resetPasswordButton.setTitle("비밀번호 재설정 메일 보내기", for: .normal)
        resetPasswordButton.setTitleColor(.systemPink, for: .normal)
        resetPasswordButton.addTarget(self, action: #selector(TappedReset), for: .touchUpInside)
        
        privacyPolicyButton.setTitle("개인정보처리방침 보기", for: .normal)
        privacyPolicyButton.setTitleColor(.systemBlue, for: .normal)
        privacyPolicyButton.addTarget(self, action: #selector(TappedPrivacyPolicy), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [emailLabel, phoneLabel, logoutButton, privacyPolicyButton, resetPasswordButton, deleteButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    private func loadUserInfo() {
        guard let user = Auth.auth().currentUser else { return }
        emailLabel.text = "이메일: \(user.email ?? "없음")"
        phoneLabel.text = "전화번호: \(user.phoneNumber ?? "없음")"
    }
    
    private func updateAuthButtonTitle() {
        if Auth.auth().currentUser != nil {
            logoutButton.setTitle("로그아웃", for: .normal)
        } else {
            logoutButton.setTitle("로그인", for: .normal)
        }
    }
    
    @objc private func TappedLogout() {
        if Auth.auth().currentUser != nil {
            // 로그아웃 처리
            do {
                try Auth.auth().signOut()
                updateAuthButtonTitle()
                print("로그아웃 성공")
            } catch {
                print("로그아웃 실패: \(error.localizedDescription)")
            }
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    @objc private func TappedReset() {
        guard let email = Auth.auth().currentUser?.email else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("비밀번호 재설정 실패: \(error.localizedDescription)")
            } else {
                print("비밀번호 재설정 메일 전송 완료")
            }
        }
    }
    
    @objc private func TappedDelet() {
        guard let user = Auth.auth().currentUser else { return }
        
        let alert = UIAlertController(title: "회원탈퇴", message: "정말 탈퇴하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "탈퇴", style: .destructive, handler: { _ in
            user.delete { error in
                if let error = error {
                    print("회원탈퇴 실패: \(error.localizedDescription)")
                    return
                }
                Firestore.firestore().collection("users").document(user.uid).delete()
                print("회원탈퇴 및 데이터 삭제 완료")
                self.navigationController?.popToRootViewController(animated: true)
                
            }
        }))
    }
    
    @objc private func TappedPrivacyPolicy() {
        if let url = Bundle.main.url(forResource: "privacyPolicy", withExtension: "pdf") {
            let pdfVC = UIViewController()
            let pdfView = PDFView()
            pdfView.autoScales = true
            pdfView.document = PDFDocument(url: url)
            pdfVC.view = pdfView
            navigationController?.pushViewController(pdfVC, animated: true)
        } else {
            print("❌ PDF 파일을 찾을 수 없습니다")
        }
    }
}

