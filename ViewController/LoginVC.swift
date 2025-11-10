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
import CryptoKit

final class LoginVC: UIViewController {
    
    private var currentNonce: String?
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let signupButton = UIButton(type: .system)
    private let resetPasswordButton = UIButton(type: .system)
    private let appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
    }
    
    // MARK: - UI 설정
    private func setupUI() {
        emailTextField.placeholder = "이메일"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        
        passwordTextField.placeholder = "비밀번호"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        
        loginButton.setTitle("로그인", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        
        signupButton.setTitle("회원가입", for: .normal)
        signupButton.setTitleColor(.systemGray, for: .normal)
        signupButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        resetPasswordButton.setTitle("비밀번호 재설정", for: .normal)
        resetPasswordButton.setTitleColor(.systemBlue, for: .normal)
        resetPasswordButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        appleLoginButton.cornerRadius = 8
        appleLoginButton.translatesAutoresizingMaskIntoConstraints = false
        appleLoginButton.isUserInteractionEnabled = true
        
        let stack = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton,
            signupButton,
            resetPasswordButton,
            appleLoginButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        view.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            signupButton.heightAnchor.constraint(equalToConstant: 44),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - 버튼 액션
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(goToSignup), for: .touchUpInside)
        resetPasswordButton.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
    }
    
    // MARK: - 이메일 로그인
    @objc private func handleLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "입력 오류", message: "이메일과 비밀번호를 모두 입력해주세요.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "로그인 실패", message: error.localizedDescription)
                return
            }
            
            print("✅ 이메일 로그인 성공:", result?.user.uid ?? "unknown")
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    // MARK: - 회원가입 이동
    @objc private func goToSignup() {
        let signupVC = SignupVC()
        navigationController?.pushViewController(signupVC, animated: true)
    }
    
    // MARK: - 비밀번호 재설정
    @objc private func handleResetPassword() {
        let alert = UIAlertController(title: "비밀번호 재설정", message: "가입한 이메일을 입력해주세요.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "이메일" }
        alert.addAction(UIAlertAction(title: "전송", style: .default) { _ in
            guard let email = alert.textFields?.first?.text, !email.isEmpty else { return }
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    self.showAlert(title: "전송 실패", message: error.localizedDescription)
                } else {
                    self.showAlert(title: "전송 완료", message: "비밀번호 재설정 이메일이 전송되었습니다.")
                }
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Apple 로그인
    @objc private func handleAppleLogin() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        currentNonce = randomNonceString()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(currentNonce!)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Apple Login Delegate
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window ?? UIWindow()
    }
}

extension LoginVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        print("❌ Apple 로그인 실패:", error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            guard
                let identityToken = appleIDCredential.identityToken,
                let tokenString = String(data: identityToken, encoding: .utf8),
                let rawNonce = currentNonce
            else {
                print("❌ Apple 토큰 없음")
                return
            }
            
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: tokenString,
                rawNonce: rawNonce
            )
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ Firebase 로그인 실패:", error.localizedDescription)
                    return
                }
                
                guard let user = authResult?.user else { return }
                print("✅ Firebase 로그인 성공:", user.uid)
                
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(user.uid)
                
                userRef.getDocument { snapshot, _ in
                    if let snapshot = snapshot, snapshot.exists {
                        print("🔹 기존 사용자 문서 존재")
                    } else {
                        userRef.setData([
                            "uid": user.uid,
                            "email": user.email ?? "비공개",
                            "nickname": "닉네임 미설정",
                            "phoneNumber": "",
                            "createdAt": FieldValue.serverTimestamp()
                        ]) { err in
                            if let err = err {
                                print("❌ Firestore 문서 생성 실패:", err.localizedDescription)
                            } else {
                                print("✅ Firestore 사용자 문서 생성 완료")
                            }
                        }
                    }
                }
                
                // ✅ 탭바 깨짐 방지: 팝뷰 복귀
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        default:
            break
        }
    }
}

// MARK: - Nonce Helper
extension LoginVC {
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
