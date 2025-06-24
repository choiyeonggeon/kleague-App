import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

class CommunityWriteVC: UIViewController {
    
    
    var editingPost: Post?
    private let titleField = UITextField()
    private let contentTextView = UITextView()
    private let teamPicker = UIPickerView()
    private let submitButton = UIButton(type: .system)
    
    private let teams = ["전체", "서울", "서울E", "인천", "부천", "김포",
                         "성남", "수원", "수원FC", "안양", "안산", "화성",
                         "대전", "충북청주", "충남아산", "천안", "김천상무", "대구FC",
                         "전북", "전남", "광주FC", "포항", "울산", "부산", "경남", "제주SK"]
    
    private var selectedTeam: String? = "전체"
    private var userTeam: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        teamPicker.dataSource = self
        teamPicker.delegate = self
        setupWriteUI()
        checkUserTeam()
        
        if let post = editingPost {
            title = "게시글 수정"
            titleField.text = post.title
            contentTextView.text = post.content
            if let index = teams.firstIndex(of: post.team) {
                teamPicker.selectRow(index, inComponent: 0, animated: false)
                selectedTeam = post.team
            }
            submitButton.setTitle("수정 완료", for: .normal)
        } else {
            title = "글쓰기"
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func checkUserTeam() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(), let team = data["team"] as? String, team != "선택 안 함" {
                self?.userTeam = team
                self?.restrictTeamSelection()
            } else {
                self?.showAlert(message: "응원 팀을 선택해야 글쓰기가 가능합니다.") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
         
        }
    }
    
    private func restrictTeamSelection() {
        guard editingPost == nil else { return }
        teams.enumerated().forEach { index, name in
            if name != "전체" && name != userTeam {
                teamPicker.selectRow(teams.firstIndex(of: userTeam!) ?? 0, inComponent: 0, animated: false)
                selectedTeam = userTeam
            }
        }
    }
    
    private func setupWriteUI() {
        
        titleField.placeholder = "제목을 입력하세요"
        titleField.borderStyle = .roundedRect
        
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 8
        
        submitButton.setTitle("등록하기", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        
        [titleField, contentTextView, teamPicker, submitButton].forEach {
            view.addSubview($0)
        }
        
        titleField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(200)
        }
        
        teamPicker.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        submitButton.snp.makeConstraints {
            $0.top.equalTo(teamPicker.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(44)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func didTapSubmit() {
        guard
            let title = titleField.text, !title.isEmpty,
            let content = contentTextView.text, !content.isEmpty,
            let team = selectedTeam,
            let user = Auth.auth().currentUser
        else {
            showAlert(message: "모든 항목을 입력해주세요.")
            return
        }
        
        let postData: [String: Any] = [
            "title": title,
            "content": content,
            "team": team,
            "likes": 0,
            "dislikes": 0,
            "commentsCount": 0,
            "author": user.email ?? "알 수 없음",
            "authorUid": user.uid,
            "showReportAlert": false,
            "createdAt": Timestamp()
        ]
        
        if let editingPost = editingPost {
            Firestore.firestore().collection("posts").document(editingPost.id).updateData(postData) { error in
                if let error = error {
                    self.showAlert(message: "글 수정 실패: \(error.localizedDescription)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            var newPostData = postData
            newPostData["likes"] = 0
            newPostData["dislikes"] = 0
            newPostData["commentsCount"] = 0
            newPostData["createdAt"] = Timestamp()
            newPostData["showReportAlert"] = false
            
            Firestore.firestore().collection("posts").addDocument(data: newPostData) { error in
                if let error = error {
                    self.showAlert(message: "글 등록 실패: \(error.localizedDescription)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
        
    }
}

// MARK: - UIPickerViewDataSource & Delegate
extension CommunityWriteVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        teams.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        teams[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTeam = teams[row]
    }
}
