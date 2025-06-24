import UIKit
import SnapKit
import PDFKit
import FirebaseAuth
import FirebaseFirestore

class SignupVC: UIViewController {
    
    // MARK: - UI Elements
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let confirmPasswordTextField = UITextField()
    private let phoneTextField = UITextField()
    private let codeTextField = UITextField()
    private let requestCodeButton = UIButton(type: .system)
    
    private let termsLabel = UILabel()
    private let termsSwitch = UISwitch()
    
    private let teamPicker = UIPickerView()
    private let teamLabel = UILabel()
    private let teams = ["선택 안 함", "서울", "서울E", "인천", "부천", "김포",
                         "성남", "수원", "수원FC", "안양", "안산", "화성",
                         "대전", "충북청주", "충남아산", "천안", "김천상무", "대구FC",
                         "전북", "전남", "광주FC", "포항", "울산", "부산", "경남", "제주SK"]
    private var selectedTeam: String? = "선택 안 함"
    
    private let signupButton = UIButton()
    private let verifyCodeButton = UIButton()
    
    private let successLabel = UILabel()
    private let errorLabel = UILabel()
    private let privacyButtton = UIButton(type: .system)
    
    private var verificationID: String?
    private var verificationCredential: PhoneAuthCredential?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        checkLastLoginAndLogoutIfNeeded()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
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
        
        codeTextField.placeholder = "인증번호 입력"
        codeTextField.borderStyle = .roundedRect
        codeTextField.keyboardType = .numberPad
        
        teamLabel.text = "응원 팀 선택 (선택 후 변경 불가)"
        teamPicker.delegate = self
        teamPicker.dataSource = self
        
        termsLabel.text = "앱 이용 약관에 동의합니다."
        termsLabel.font = .systemFont(ofSize: 14)
        
        privacyButtton.setTitle("보기", for: .normal)
        privacyButtton.setTitleColor(.blue, for: .normal)
        privacyButtton.titleLabel?.font = .systemFont(ofSize: 14)
        privacyButtton.addTarget(self, action: #selector(pdfVC), for: .touchUpInside)
        
        successLabel.textColor = .systemGreen
        successLabel.font = .systemFont(ofSize: 14)
        successLabel.textAlignment = .center
        successLabel.numberOfLines = 0
        successLabel.isHidden = true
        
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        
        signupButton.setTitle("회원가입", for: .normal)
        signupButton.backgroundColor = .systemBlue
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.layer.cornerRadius = 8
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        
        requestCodeButton.setTitle("인증하기", for: .normal)
        requestCodeButton.setTitleColor(.white, for: .normal)
        requestCodeButton.backgroundColor = .systemOrange
        requestCodeButton.layer.cornerRadius = 8
        requestCodeButton.addTarget(self, action: #selector(requestCodeTapped), for: .touchUpInside)
        
        verifyCodeButton.setTitle("인증 완료", for: .normal)
        verifyCodeButton.backgroundColor = .systemGreen
        verifyCodeButton.setTitleColor(.white, for: .normal)
        verifyCodeButton.layer.cornerRadius = 8
        verifyCodeButton.addTarget(self, action: #selector(verifyCodeTapped), for: .touchUpInside)
        
        let phoneStack = UIStackView(arrangedSubviews: [phoneTextField, requestCodeButton])
        phoneStack.axis = .horizontal
        phoneStack.spacing = 8
        phoneStack.distribution = .fill
        
        requestCodeButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(44)
        }
        
        verifyCodeButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(44)
        }
        
        [phoneTextField, codeTextField].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(44) }
        }
        
        let codeStack = UIStackView(arrangedSubviews: [codeTextField, verifyCodeButton])
        codeStack.axis = .horizontal
        codeStack.spacing = 8
        codeStack.distribution = .fill
        
        let termsStack = UIStackView(arrangedSubviews: [termsLabel, privacyButtton, termsSwitch])
        termsStack.axis = .horizontal
        termsStack.spacing = 8
        termsStack.alignment = .center
        
        let stack = UIStackView(arrangedSubviews: [
            emailTextField, passwordTextField, confirmPasswordTextField,
            phoneStack, codeStack, termsStack,
            teamLabel, teamPicker,
            signupButton, successLabel, errorLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        [emailTextField, passwordTextField, confirmPasswordTextField,
         phoneTextField, codeTextField, signupButton, verifyCodeButton, requestCodeButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
    }
    
    private func checkLastLoginAndLogoutIfNeeded() {
        guard let user = Auth.auth().currentUser else { return }
        
        let userDoc = Firestore.firestore().collection("users").document(user.uid)
        userDoc.getDocument { [weak self] snapshot, error in
            if let error = error {
                print("사용자 정보 불러오기 실패: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
            let lastLoginTimestamp = data["lastLogin"] as? Timestamp
            else { return }
            
            let lastLoginDate = lastLoginTimestamp.dateValue()
            let now = Date()
            let diff = now.timeIntervalSince(lastLoginDate)
            let thirtyDays: TimeInterval = 30 * 24 * 60 * 60
            
            if diff > thirtyDays {
                do {
                    try Auth.auth().signOut()
                    DispatchQueue.main.async {
                        self?.showError("30일 동안 미접속으로 자동 로그아웃되었습니다. 다시 로그인해주세요.")
                        self?.navigationController?.popViewController(animated: true)
                    }
                } catch {
                    print("로그인 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func handleSignup() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text else {
            showError("모든 항목을 입력해주세요.")
            return
        }
        
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
        
        guard let credential = verificationCredential else {
            showError("전화번호 인증을 완료해주세요.")
            return
        }
        
        guard let phone = phoneTextField.text else {
            showError("전화번호를 확인할 수 없습니다.")
            return
        }
        
        if selectedTeam == "선택 안 함" {
            showError("응원 팀을 선택해주세요. (선택 후 변경 불가)")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showError("회원가입 실패: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else {
                self.showError("회원가입 중 문제가 발생했습니다.")
                return
            }
            
            user.link(with: credential) { linkResult, linkError in
                if let linkError = linkError {
                    self.showError("전화번호 연결 실패: \(linkError.localizedDescription)")
                    return
                }
                
                let userData: [String: Any] = [
                    "email": email,
                    "phone": phone,
                    "team": self.selectedTeam ?? "선택 안 함",
                    "createdAt": Timestamp(),
                    "lastLogin": Timestamp()
                ]
                
                Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        self.showError("사용자 정보 저장 실패: \(error.localizedDescription)")
                        return
                    }
                    
                    self.showSuccess("회원가입이 완료되었습니다.")
                    
                    // 이미 로그인된 상태이므로 별도 로그인 절차 없이 메인 화면으로 이동
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let mainVC = MoreVC()  // 실제 메인 화면 VC로 교체 가능
                        let nav = UINavigationController(rootViewController: mainVC)
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController = nav
                            window.makeKeyAndVisible()
                        }
                    }
                }
            }
        }
    }
    
    @objc private func requestCodeTapped() {
        guard let phone = phoneTextField.text, !phone.isEmpty else {
            showError("휴대폰 번호를 입력해주세요.")
            return
        }
        startPhoneVerification(phoneNumber: phone)
    }
    
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
    
    @objc private func verifyCodeTapped() {
        guard let verificationID = verificationID,
              let code = codeTextField.text, !code.isEmpty else {
            showError("인증번호를 입력해주세요.")
            return
        }
        
        verificationCredential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        showSuccess("전화번호 인증 성공! 회원가입을 완료해주세요.")
    }
    
    private func showSuccess(_ message: String) {
        successLabel.text = message
        successLabel.isHidden = false
        errorLabel.isHidden = true
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        successLabel.isHidden = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let regex = "^(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    
    @objc private func pdfVC() {
        let vc = PDFViewerVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SignupVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        teams.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        teams[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let team = teams[row]
        
        if selectedTeam == "선택 안 함" || selectedTeam == nil {
            selectedTeam = team
        } else {
            showError("응원 팀은 한번 선택하면 변경할 수 없습니다.")
            if let index = teams.firstIndex(of: selectedTeam ?? "선택 안 함") {
                pickerView.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }
}
