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
    
    private let teams = [
        "서울", "서울E", "인천", "부천", "김포", "성남", "수원", "수원FC", "안양", "안산", "화성",
        "대전", "충북청주", "충남아산", "천안", "김천상무", "대구FC", "전북", "전남", "광주FC",
        "포항", "울산", "부산", "경남", "제주SK"
    ]
    
    private let teamLabel = UILabel()
    private let emailLabel = UILabel()
    private let phoneLabel = UILabel()
    private let logoutButton = UIButton()
    private let deleteButton = UIButton()
    private let resetPasswordButton = UIButton()
    private let privacyPolicyButton = UIButton()
    private let teamPickerView = UIPickerView()
    private let pickerTextField = UITextField()
    private let selectTeamButton = UIButton(type: .system)
    private let manageBlockedUsersButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "개인정보"
        setupPersonal()
        updateButtonVisibility()
        loadUserInfo()
        
        teamPickerView.delegate = self
        teamPickerView.dataSource = self
        
        pickerTextField.inputView = teamPickerView
        setupPickerToolbar()   // 툴바(완료 버튼) 세팅 추가
        view.addSubview(pickerTextField)
        pickerTextField.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAuthButtonTitle()
        updateButtonVisibility()
        loadUserInfo()
    }
    
    private func updateButtonVisibility() {
        let isLoggedIn = Auth.auth().currentUser != nil
        selectTeamButton.isHidden = !isLoggedIn
        resetPasswordButton.isHidden = !isLoggedIn
        deleteButton.isHidden = !isLoggedIn
        manageBlockedUsersButton.isHidden = !isLoggedIn
    }
    
    private func setupPersonal() {
        emailLabel.font = .systemFont(ofSize: 17, weight: .medium)
        phoneLabel.font = .systemFont(ofSize: 17, weight: .medium)
        teamLabel.font = .systemFont(ofSize: 17, weight: .medium)
        
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.setTitleColor(.systemBlue, for: .normal)
        logoutButton.addTarget(self, action: #selector(TappedLogout), for: .touchUpInside)
        
        deleteButton.setTitle("회원탈퇴", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.addTarget(self, action: #selector(TappedDelet), for: .touchUpInside)
        
        resetPasswordButton.setTitle("비밀번호 재설정 메일 보내기", for: .normal)
        resetPasswordButton.setTitleColor(.systemPink, for: .normal)
        resetPasswordButton.addTarget(self, action: #selector(TappedReset), for: .touchUpInside)
        
        manageBlockedUsersButton.setTitle("차단한 사용자 목록", for: .normal)
        manageBlockedUsersButton.setTitleColor(.systemBlue, for: .normal)
        manageBlockedUsersButton.addTarget(self, action: #selector(didTapManageBlockedUsers), for: .touchUpInside)
        
        privacyPolicyButton.setTitle("개인정보처리방침 보기", for: .normal)
        privacyPolicyButton.setTitleColor(.systemBlue, for: .normal)
        privacyPolicyButton.addTarget(self, action: #selector(TappedPrivacyPolicy), for: .touchUpInside)
        
        selectTeamButton.setTitle("팀 선택", for: .normal)
        selectTeamButton.setTitleColor(.systemBlue, for: .normal)
        selectTeamButton.addTarget(self, action: #selector(didTapSelectTeam), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [
            emailLabel,
            phoneLabel,
            teamLabel,
            selectTeamButton,
            logoutButton,
            privacyPolicyButton,
            manageBlockedUsersButton,
            resetPasswordButton,
            deleteButton
        ])
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
        guard let user = Auth.auth().currentUser else {
            emailLabel.text = "이메일: 없음"
            phoneLabel.text = "전화번호: 없음"
            teamLabel.text = "응원팀: 미선택"
            return
        }
        emailLabel.text = "이메일: \(user.email ?? "없음")"
        phoneLabel.text = "전화번호: \(user.phoneNumber ?? "없음")"
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                self.teamLabel.text = "응원팀: 미선택"
                self.selectTeamButton.isEnabled = true
                self.selectTeamButton.setTitle("팀 선택", for: .normal)
                return
            }
            if let team = data["team"] as? String {
                self.teamLabel.text = "응원팀: \(team)"
                self.selectTeamButton.isEnabled = false
                self.selectTeamButton.setTitle("팀 선택 완료", for: .normal)
            } else {
                self.teamLabel.text = "응원팀: 미선택"
                self.selectTeamButton.isEnabled = true
                self.selectTeamButton.setTitle("팀 선택", for: .normal)
            }
        }
    }
    
    @objc private func didTapSelectTeam() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            if data["team"] != nil {
                print("❌ 이미 팀을 선택했습니다.")
                return
            }
            
            self.pickerTextField.becomeFirstResponder()
        }
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
            do {
                try Auth.auth().signOut()
                updateAuthButtonTitle()
                updateButtonVisibility()
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
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlert(title: "실패", message: "비밀번호 재설정 메일 전송 실패: \(error.localizedDescription)")
                } else {
                    self.showAlert(title: "성공", message: "비밀번호 재설정 메일이 전송되었습니다.")
                }
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
        present(alert, animated: true)
    }
    
    @objc private func TappedPrivacyPolicy() {
        if let url = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "pdf") {
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
    
    private func setupPickerToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(didTapPickerDone))
        
        toolbar.setItems([flexSpace, doneButton], animated: false)
        
        pickerTextField.inputAccessoryView = toolbar
    }
    
    @objc private func didTapManageBlockedUsers() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("blockedUsers")
            .getDocuments { snapshot, error in
                if let error = error {
                    self.showAlert(title: "오류", message: "차단 목록을 불러올 수 없습니다.: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.showAlert(title: "차단한 사용자 없음", message: "현재 차단한 사용자가 없습니다.")
                    return
                }
                
                var blockedUsersInfo: [(uid: String, nickname: String)] = []
                let group = DispatchGroup()
                
                for doc in documents {
                    let blockedUid = doc.documentID  // ✅ 오타 수정: doc.docmentID → doc.documentID
                    group.enter()
                    db.collection("users").document(blockedUid).getDocument { userDoc, error in
                        if let data = userDoc?.data(), error == nil {
                            let nickname = data["nickname"] as? String ?? blockedUid
                            blockedUsersInfo.append((uid: blockedUid, nickname: nickname))
                        } else {
                            blockedUsersInfo.append((uid: blockedUid, nickname: blockedUid))
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    let alert = UIAlertController(title: "차단한 사용자", message: "차단 해제할 사용자를 선택하세요.", preferredStyle: .actionSheet)  // ✅ preferredStyle 설정 완료
                    
                    for userInfo in blockedUsersInfo {
                        let unblockAction = UIAlertAction(title: userInfo.nickname, style: .default) { _ in
                            db.collection("users").document(uid)
                                .collection("blockedUsers").document(userInfo.uid).delete { err in
                                    if let err = err {
                                        self.showAlert(title: "실패", message: "차단 해제 실패: \(err.localizedDescription)")
                                    } else {
                                        self.showAlert(title: "차단 해제", message: "\(userInfo.nickname) 님 차단이 해제되었습니다.")
                                    }
                                }
                        }
                        alert.addAction(unblockAction)
                    }
                    
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                    
                    // ✅ iPad에서도 crash 방지용 popover 설정
                    if let popoverController = alert.popoverPresentationController {
                        popoverController.sourceView = self.view
                        popoverController.sourceRect = CGRect(
                            x: self.view.bounds.midX,
                            y: self.view.bounds.midY,
                            width: 1,
                            height: 1
                        )
                        popoverController.permittedArrowDirections = []
                    }
                    
                    self.present(alert, animated: true)
                }
            }
    }
    
    @objc private func didTapPickerDone() {
        let selectedRow = teamPickerView.selectedRow(inComponent: 0)
        let selectedTeam = teams[selectedRow]
        
        guard let uid = Auth.auth().currentUser?.uid else {
            pickerTextField.resignFirstResponder()
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                self.pickerTextField.resignFirstResponder()
                return
            }
            if data["team"] != nil {
                print("❌ 이미 팀을 선택했습니다.")
                self.pickerTextField.resignFirstResponder()
                return
            }
            
            userRef.updateData(["team": selectedTeam]) { error in
                if let error = error {
                    print("❌ 팀 저장 실패: \(error.localizedDescription)")
                } else {
                    self.teamLabel.text = "응원팀: \(selectedTeam)"
                    self.selectTeamButton.isEnabled = false
                    self.selectTeamButton.setTitle("팀 선택 완료", for: .normal)
                    print("✅ 팀 저장 완료")
                }
                self.pickerTextField.resignFirstResponder()
            }
        }
    }
}

extension PersonalInformationVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teams.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teams[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 필요 시 선택 시 처리
    }
}

// UIAlertController를 쉽게 호출하기 위한 확장
extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "확인", style: .default) { _ in completion?() })
        present(alertVC, animated: true)
    }
}
