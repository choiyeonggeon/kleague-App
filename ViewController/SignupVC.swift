//
//  SignupVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/9/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class SignupVC: UIViewController {
    
    private let termsLabel = UILabel()
    private let termsSwitch = UISwitch()
    private let errorLabel = UILabel()
    private let emailTextField = UITextField()
    private let emailLabel = UILabel()
    private let emailError = UILabel()
    private let passwordTextField = UITextField()
    private let confirmPasswordLabel = UILabel()
    private let passwordLabel = UILabel()
    private let confirmPasswordTextField = UITextField()
    private let signupButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSigne()
    }
    
    private func setupSigne() {
        view.backgroundColor = .white
        
        emailTextField.placeholder = "이메일"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        
        passwordTextField.placeholder = "비밀번호 (8자 이상, 특수문자 포함)"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        
        confirmPasswordTextField.placeholder = "비밀번호 확인"
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.borderStyle = .roundedRect
        
        termsLabel.text = "앱 이용 약관에 동의합니다."
        termsLabel.font = .systemFont(ofSize: 14)
        
        signupButton.setTitle("회원가입", for: .normal)
        signupButton.backgroundColor = .systemGray
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.layer.cornerRadius = 8
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        
        errorLabel.textColor = .red
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        
        let termsStack = UIStackView(arrangedSubviews: [termsLabel, termsSwitch])
        termsStack.axis = .horizontal
        termsStack.spacing = 8
        termsStack.alignment = .center
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, confirmPasswordTextField, termsStack, errorLabel, signupButton])
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
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            signupButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func handleSignup() {
        errorLabel.isHidden = true
        guard let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else { return }
        
        guard isValidEmail(email) else {
            showError("올바른 이메일 형식을 입력해주세요.")
            return
        }
        
        guard isValidPassword(password) else {
            showError("비밀번호는 8자 이상이며 특수문자를 포함해야 합니다.")
            return
        }
        
        guard password == confirmPassword else {
            showError("비밀번호가 일치하지 않습니다.")
            return
        }
        
        guard termsSwitch.isOn else {
            showError("약관에 동의해야 회원가입이 가능합니다.")
            return
        }
        
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
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}

