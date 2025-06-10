//
//  SignupVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/9/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignupVC: UIViewController {
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let signupButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSigne()
    }
    
    private func setupSigne() {
        view.backgroundColor = .white
        
        emailTextField.placeholder = "이메일"
        emailTextField.borderStyle = .roundedRect
        
        passwordTextField.placeholder = "비밀번호"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        
        signupButton.setTitle("회원가입", for: .normal)
        signupButton.backgroundColor = .systemGray
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.layer.cornerRadius = 8
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signupButton])
        stack.axis = .vertical
        stack.spacing = 16
        self.view.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            signupButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func handleSignup() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("회원가입 실패: \(error.localizedDescription)")
                return
            }
            print("회원가입 성공: \(result?.user.uid ?? "")")
            
            let db = Firestore.firestore()
            db.collection("users").document(result!.user.uid).setData([
                "email": email,
                "createdAt": Timestamp()
            ]) { error in
                if let error = error {
                    print("DB 저장 실패: \(error.localizedDescription)")
                    return
                }
                print("DB 저장 성공")
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}
