//
//  LoginVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/6/25.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton()
    private let signupButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLoginVC()
    }
    
    private func setupLoginVC() {
        
        emailTextField.placeholder = "이메일"
        emailTextField.borderStyle = .roundedRect
        passwordTextField.placeholder = "비밀번호"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        
        loginButton.setTitle( "로그인", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = 8
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        signupButton.setTitle("회원가입", for: .normal)
        signupButton.backgroundColor = .systemGray
        signupButton.layer.cornerRadius = 8
        signupButton.addTarget(self, action: #selector(goToSignup), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, signupButton])
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            signupButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("로그인 실패: \(error.localizedDescription)")
                return
            }
            print("로그인 성공: \(result?.user.uid ?? "")")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    @objc private func goToSignup() {
           let signupVC = SignupVC()
           navigationController?.pushViewController(signupVC, animated: true)
       }
}
