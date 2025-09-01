//
//  LoginVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/6/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser

class LoginVC: UIViewController, UITextFieldDelegate {
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let errorLabel = UILabel()
    private let loginButton = UIButton()
    private let signupButton = UIButton()
    
    private let kakaoLoginButton = UIButton(type: .system)
    private let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLoginVC()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupLoginVC() {
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
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
        
        kakaoLoginButton.backgroundColor = .clear
        kakaoLoginButton.layer.cornerRadius = 8
        
        
        // MARK: - 카카오 로그인 버튼
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(named: "kakao_logo")
            config.imagePlacement = .leading // 왼쪽에 이미지
            config.imagePadding = 10         // 이미지와 타이틀 간격
            config.baseForegroundColor = .black
            config.cornerStyle = .medium
            kakaoLoginButton.configuration = config
        } else {
            kakaoLoginButton.setImage(UIImage(named: "kakao_logo"), for: .normal)
            kakaoLoginButton.setTitleColor(.black, for: .normal)
            kakaoLoginButton.layer.cornerRadius = 8
            kakaoLoginButton.imageView?.contentMode = .scaleAspectFit
            kakaoLoginButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
            kakaoLoginButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        }
        kakaoLoginButton.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
        
        // MARK: - 애플 로그인 버튼
        appleLoginButton.cornerRadius = 8
        appleLoginButton.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton,
            signupButton,
            kakaoLoginButton,
            appleLoginButton
        ])
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
            signupButton.heightAnchor.constraint(equalToConstant: 44),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 50),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("로그인 실패: \(error.localizedDescription)")
                
                let alert = UIAlertController(title: "로그인 실패", message: "이메일 또는 비밀번호를 다시 확인해주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
                
                return
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - 카카오 로그인
    @objc private func handleKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print("카카오톡 로그인 실패: \(error)")
                } else {
                    print("카카오톡 로그인 성공, 토큰: \(String(describing: oauthToken?.accessToken))")
                    // Firebase 연동이나 사용자 정보 처리 로직 추가
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print("카카오 계정 로그인 실패: \(error)")
                } else {
                    print("카카오 계정 로그인 성공, 토큰: \(String(describing: oauthToken?.accessToken))")
                    // Firebase 연동이나 사용자 정보 처리 로직 추가
                }
            }
        }
    }
    
    // MARK: - 애플 로그인
    @objc private func handleAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName ,.email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func goToSignup() {
        let signupVC = SignupVC()
        navigationController?.pushViewController(signupVC, animated: true)
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginVC: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print("Apple 로그인 성공: \(userIdentifier), \(String(describing: fullName)), \(String(describing: email))")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple 로그인 실패: \(error)")
    }
    
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return.self.view.window!
//    }
}
