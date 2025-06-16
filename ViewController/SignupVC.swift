//
//  SignupVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/9/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class SignupVC: UIViewController, UITextFieldDelegate, AuthUIDelegate {
    
    private let termsLabel = UILabel()
    private let termsSwitch = UISwitch()
    private let errorLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let signupButton = UIButton(type: .system)
    
    private let phoneTextField = UITextField()
    private let verifyCodeTextField = UITextField()
    private let sendCodeButton = UIButton(type: .system)
    private let verifiButton = UIButton(type: .system)
    private var verificationID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSigne()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupSigne() {
        view.backgroundColor = .white
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        emailTextField.placeholder = "이메일"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        
        passwordTextField.placeholder = "비밀번호 (8자 이상, 특수문자 포함)"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        
        confirmPasswordTextField.placeholder = "비밀번호 확인"
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.borderStyle = .roundedRect
        
        phoneTextField.placeholder = "휴대폰 번호 (+821012345678)"
        phoneTextField.borderStyle = .roundedRect
        phoneTextField.keyboardType = .phonePad
        
        verifyCodeTextField.placeholder = "인증번호 입력"
        verifyCodeTextField.borderStyle = .roundedRect
        verifyCodeTextField.keyboardType = .numberPad
        verifyCodeTextField.isHidden = true
        
        sendCodeButton.setTitle("인증번호 전송", for: .normal)
        sendCodeButton.addTarget(self, action: #selector(sendVerificationCode), for: .touchUpInside)
        
        verifiButton.setTitle("인증 확인", for: .normal)
        verifiButton.addTarget(self, action: #selector(verifyCode), for: .touchUpInside)
        verifiButton.isHidden = true
        
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
        
        
        stack.insertArrangedSubview(phoneTextField, at: 3)
        stack.insertArrangedSubview(sendCodeButton, at: 4)
        stack.insertArrangedSubview(verifyCodeTextField, at: 5)
        stack.insertArrangedSubview(verifiButton, at: 6)
        
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func sendVerificationCode() {
        guard let phoneNumber = phoneTextField.text, !phoneNumber.isEmpty else {
            showError("휴대폰 번호를 입력해주세요.")
            return
        }

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }

            if let error = error {
                self.showError("인증번호 전송 실패: \(error.localizedDescription)")
                return
            }

            guard let verificationID = verificationID else {
                self.showError("인증번호 전송에 실패했습니다.")
                return
            }

            self.verificationID = verificationID
            self.showError("인증번호가 전송되었습니다.")
            self.verifyCodeTextField.isHidden = false
            self.verifiButton.isHidden = false
        }
    }
    
    @objc private func verifyCode() {
        guard let verificationID = verificationID,
              let verificationCode = verifyCodeTextField.text, !verificationCode.isEmpty else {
            showError("인증 코드를 입력해주세요.")
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            self.showError("휴대폰 인증 성공")
            print("Phone Auth User UID: \(authResult?.user.uid ?? "")")
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
