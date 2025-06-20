import UIKit
import FirebaseAuth
import FirebaseFirestore
import SnapKit

class SignupVC: UIViewController {
    
    // MARK: - UI Elements
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let phoneTextField = UITextField()
    private let codeTextField = UITextField()
    
    private let signupButton = UIButton()
    private let verifyCodeButton = UIButton()
    
    private let successLabel = UILabel()
    private let errorLabel = UILabel()

    // MARK: - Properties
    private var verificationID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: - UI Setup
    private func setupUI() {
        emailTextField.placeholder = "이메일"
        passwordTextField.placeholder = "비밀번호"
        passwordTextField.isSecureTextEntry = true
        phoneTextField.placeholder = "휴대폰 번호 (+821012345678)"
        codeTextField.placeholder = "인증번호 입력"
        
        signupButton.setTitle("회원가입", for: .normal)
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.backgroundColor = .systemBlue
        signupButton.layer.cornerRadius = 8
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        
        verifyCodeButton.setTitle("인증 확인", for: .normal)
        verifyCodeButton.setTitleColor(.white, for: .normal)
        verifyCodeButton.backgroundColor = .systemGreen
        verifyCodeButton.layer.cornerRadius = 8
        verifyCodeButton.addTarget(self, action: #selector(verifyCodeTapped), for: .touchUpInside)
        
        successLabel.textColor = .systemGreen
        successLabel.numberOfLines = 0
        successLabel.font = .systemFont(ofSize: 14)
        successLabel.isHidden = true
        successLabel.textAlignment = .center
        
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.isHidden = true
        errorLabel.textAlignment = .center

        [emailTextField, passwordTextField, phoneTextField, codeTextField,
         signupButton, verifyCodeButton, successLabel, errorLabel].forEach {
            $0.layer.borderWidth = 0.5
            $0.layer.cornerRadius = 6
            view.addSubview($0)
        }

        emailTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }

        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(12)
            $0.leading.trailing.height.equalTo(emailTextField)
        }

        phoneTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(12)
            $0.leading.trailing.height.equalTo(emailTextField)
        }

        codeTextField.snp.makeConstraints {
            $0.top.equalTo(phoneTextField.snp.bottom).offset(12)
            $0.leading.trailing.height.equalTo(emailTextField)
        }

        signupButton.snp.makeConstraints {
            $0.top.equalTo(codeTextField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(80)
            $0.height.equalTo(44)
        }

        verifyCodeButton.snp.makeConstraints {
            $0.top.equalTo(signupButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(80)
            $0.height.equalTo(44)
        }

        successLabel.snp.makeConstraints {
            $0.top.equalTo(verifyCodeButton.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        errorLabel.snp.makeConstraints {
            $0.top.equalTo(successLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    // MARK: - Actions

    /// 1. 회원가입
    @objc private func signupTapped() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let phone = phoneTextField.text else {
            showError("모든 필드를 입력해주세요.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showError("회원가입 실패: \(error.localizedDescription)")
                return
            }

            self?.showSuccess("회원가입 성공! 휴대폰 인증을 진행해주세요.")
            self?.startPhoneVerification(phoneNumber: phone)
        }
        
        print("🔥 UID: \(Auth.auth().currentUser?.uid ?? "없음")")
        print("🔥 Email: \(Auth.auth().currentUser?.email ?? "없음")")
        print("🔥 Phone: \(Auth.auth().currentUser?.phoneNumber ?? "없음")")

    }

    /// 2. 인증코드 전송
    private func startPhoneVerification(phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            if let error = error {
                self?.showError("인증번호 전송 실패: \(error.localizedDescription)")
                return
            }

            self?.verificationID = verificationID
            self?.showSuccess("인증번호가 전송되었습니다.")
        }
    }

    /// 3. 인증번호 확인 및 계정 연결
    @objc private func verifyCodeTapped() {
        guard let verificationID = verificationID,
              let code = codeTextField.text else {
            showError("인증번호를 입력해주세요.")
            return
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )

        Auth.auth().currentUser?.link(with: credential) { [weak self] authResult, error in
            if let error = error {
                self?.showError("전화번호 연결 실패: \(error.localizedDescription)")
            } else {
                self?.showSuccess("전화번호 인증이 완료되었습니다!")
                self?.navigateToCommunity()
            }
        }
    }

    // MARK: - 메시지 표시 메서드

    private func showSuccess(_ message: String) {
        DispatchQueue.main.async {
            self.successLabel.text = message
            self.successLabel.isHidden = false
            self.errorLabel.isHidden = true
        }
    }

    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
            self.successLabel.isHidden = true
        }
    }

    // MARK: - 이동
    private func navigateToCommunity() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
