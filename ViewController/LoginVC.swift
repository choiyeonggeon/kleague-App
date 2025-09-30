//
//  LoginVC.swift
//  KleagueApp
//
//  Created by 최영건 on 6/6/25.
//

import UIKit
import RxSwift
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
    private let disposeBag = DisposeBag()
    
//    private let findIdButton = UIButton()
    private let resetPasswordButton = UIButton()
    
//    private let kakaoLoginButton = UIButton(type: .system)
//    private let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
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
        
//        findIdButton.setTitle("아이디 찾기", for: .normal)
//        findIdButton.setTitleColor(.systemBlue, for: .normal)
//        findIdButton.addTarget(self, action: #selector(handleFindId), for: .touchUpInside)
        
        resetPasswordButton.setTitle("비밀번호 찾기", for: .normal)
        resetPasswordButton.setTitleColor(.systemBlue, for: .normal)
        resetPasswordButton.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        
//        kakaoLoginButton.backgroundColor = .clear
//        kakaoLoginButton.layer.cornerRadius = 8
        
        
        // MARK: - 카카오 로그인 버튼
//        if #available(iOS 15.0, *) {
//            var config = UIButton.Configuration.plain()
//            config.image = UIImage(named: "kakao_logo")
//            config.imagePlacement = .leading // 왼쪽에 이미지
//            config.imagePadding = 10         // 이미지와 타이틀 간격
//            config.baseForegroundColor = .black
//            config.cornerStyle = .medium
//            kakaoLoginButton.configuration = config
//        } else {
//            kakaoLoginButton.setImage(UIImage(named: "kakao_logo"), for: .normal)
//            kakaoLoginButton.setTitleColor(.black, for: .normal)
//            kakaoLoginButton.layer.cornerRadius = 8
//            kakaoLoginButton.imageView?.contentMode = .scaleAspectFit
//            kakaoLoginButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
//            kakaoLoginButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
//        }
//        kakaoLoginButton.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
        
        // MARK: - 애플 로그인 버튼
//        appleLoginButton.cornerRadius = 8
//        appleLoginButton.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton,
            signupButton,
//            findIdButton,
            resetPasswordButton
//            kakaoLoginButton,
//            appleLoginButton
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
            signupButton.heightAnchor.constraint(equalToConstant: 44)
//            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 50),
//            appleLoginButton.heightAnchor.constraint(equalToConstant: 50)
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
        AuthManager.shared.signInWithKakao()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { authResult in
                    print("Firebase 로그인 성공: \(authResult.user.uid)")
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
                        homeVC.modalPresentationStyle = .fullScreen
                        self.present(homeVC, animated: true, completion: nil)
                    }
                },
                onError: { error in
                    print("로그인 실패: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "로그인 실패", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                }
            )
            .disposed(by: disposeBag)
    }
    
    // MARK: - 애플 로그인
    @objc private func handleAppleLogin() {
        guard let window = view.window else { return }
        
        AuthManager.shared.signInWithApple(presentationAnchor: window)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { authResult in
                    print("애플 로그인 성공: \(authResult.user.uid)")
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
                        homeVC.modalPresentationStyle = .fullScreen
                        self.present(homeVC, animated: true, completion: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }, onError: { error in
                    print("애플 로그인 실패: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "로그인 실패", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                }
            )
            .disposed(by: disposeBag)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func goToSignup() {
        let signupVC = SignupVC()
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    @objc private func handleFindId() {
        let alert = UIAlertController(title: "아이디 찾기", message: "가입 시 사용한 전화번호를 입력해주세요.", preferredStyle: .alert)
        alert.addTextField { textFiled in
            textFiled.placeholder = "전화번호"
        }
        alert.addAction(UIAlertAction(title: "조회", style: .default, handler: { _ in
            guard let nickname = alert.textFields?.first?.text, !nickname.isEmpty else { return }
            
            Firestore.firestore().collection("users")
                .whereField("phoneNumber", isEqualTo: nickname)
                .getDocuments { snapshot, error in
                    if let error = error {
                        self.showAlert(title: "조회 실패", message: error.localizedDescription)
                        return
                    }
                    
                    if let doc = snapshot?.documents.first, let email = doc.data()["email"] as? String {
                        self.showAlert(title: "가입 이메일", message: "등록된 이메일: \(email)")
                    } else {
                        self.showAlert(title: "조회 실패", message: "해당 전화번호로 가입된 계정이 없습니다.")
                    }
                }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func handleResetPassword() {
        let alert = UIAlertController(title: "비밀번호 재설정", message: "가입한 이메일을 입력해주세요.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "이메일"
        }
        alert.addAction(UIAlertAction(title: "전송", style: .default, handler: { _ in
            guard let email = alert.textFields?.first?.text, !email.isEmpty else { return }
            
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.showAlert(title: "전송 실패", message: error.localizedDescription)
                } else {
                    self.showAlert(title: "전송 완료", message: "비밀번호 재설정 이메일이 전송되었습니다.")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}
