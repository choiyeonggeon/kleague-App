import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseFirestore

class CommunityWriteVC: UIViewController {
    
    var editingPost: Post?
    private var badWordsLoaded = false
    private var userTeamLoaded = false
    private var userNickname: String?
    private var badWords: [String] = []
    private var isBadWordAlertShown = false
    
    private let titleField = UITextField()
    private let contentTextView = UITextView()
    private let teamPicker = UIPickerView()
    private let submitButton = UIButton(type: .system)
    private let disposeBag = DisposeBag()
    
    private let teams = ["전체", "강원", "경남", "김천상무", "김포",
                         "광주FC", "대구FC", "대전", "서울", "서울E",
                         "부산", "부천", "성남", "수원", "수원FC",
                         "인천", "안양", "안산", "울산", "전북", "전남",
                         "제주SK", "충북청주", "충남아산", "천안", "포항", "화성"]
    
    private var selectedTeam: String? = "전체"
    private var userTeam: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        teamPicker.dataSource = self
        teamPicker.delegate = self
        teamPicker.isHidden = (editingPost != nil)
        
        setupWriteUI()
        loadUserTeam()
        adjustConstraintsForEditMode()
        bindInputs()
        fetchBadWords { words in
            self.badWords = words
            self.badWordsLoaded = true
            DispatchQueue.main.async {
                self.updateSubmitButtonState()
            }
        }
        
        if let post = editingPost {
            title = "게시글 수정"
            titleField.text = post.title
            contentTextView.text = post.content
            if let index = teams.firstIndex(of: post.team) {
                teamPicker.selectRow(index, inComponent: 0, animated: false)
                selectedTeam = post.team
            }
            submitButton.setTitle("수정 완료", for: .normal)
            adjustConstraintsForEditMode()
        } else {
            title = "글쓰기"
            
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
    
    private func bindInputs() {
        let titleInput = titleField.rx.text.orEmpty
        let contentInput = contentTextView.rx.text.orEmpty
        
        Observable.combineLatest(titleInput, contentInput)
            .subscribe(onNext: { [weak self] title, content in
                guard let self = self else { return }
                
                let hasTitle = !title.isEmpty
                let hasContent = !content.isEmpty
                let isBadTitle = self.containsBadWord(title, badWords: self.badWords)
                let isBadContent = self.containsBadWord(content, badWords: self.badWords)
                
                let enabled = self.badWordsLoaded && self.userTeamLoaded && hasTitle && hasContent && !isBadTitle && !isBadContent
                self.submitButton.isEnabled = enabled
                self.submitButton.alpha = enabled ? 1.0 : 0.5
                
                // 얼럿은 한 번만 띄우도록 제어
                if (isBadTitle || isBadContent) && hasTitle && hasContent {
                    if !self.isBadWordAlertShown {
                        self.isBadWordAlertShown = true
                        self.showAlert(message: "금지어가 포함되어 있습니다. 내용을 수정해주세요.") {
                            self.isBadWordAlertShown = false // 얼럿 닫힌 뒤 다시 초기화
                        }
                    }
                } else {
                    self.isBadWordAlertShown = false
                }
            })
            .disposed(by: disposeBag)
        
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
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
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
        
        titleField.addTarget(self, action: #selector(textInputChanged), for: .editingChanged)
        contentTextView.delegate = self
        
    }
    
    private func loadUserTeam() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("유저 정보 불러오기 실패:", error?.localizedDescription ?? "")
                return
            }
            
            if let team = data["team"] as? String {
                self.userTeam = team
                self.userNickname = data["nickname"] as? String
                self.userTeamLoaded = true
                DispatchQueue.main.async {
                    self.restrictTeamPickerSelection()
                    self.updateSubmitButtonState()
                    self.bindInputs()
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert(message: "팀을 선택해야 글을 작성할 수 있습니다.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func adjustConstraintsForEditMode() {
        if editingPost != nil {
            teamPicker.removeFromSuperview()
            submitButton.snp.remakeConstraints {
                $0.top.equalTo(contentTextView.snp.bottom).offset(20)
                $0.centerX.equalTo(view)
                $0.width.equalTo(120)
                $0.height.equalTo(44)
            }
        }
    }
    
    private func updateSubmitButtonState() {
        let hasTitle = !(titleField.text ?? "").isEmpty
        let hasContent = !(contentTextView.text ?? "").isEmpty
        
        let enabled = badWordsLoaded && userTeamLoaded && hasTitle && hasContent
        submitButton.isEnabled = enabled
        submitButton.alpha = enabled ? 1.0 : 0.5
    }
    
    private func restrictTeamPickerSelection() {
        // 글쓰기(새글)일 때만 userTeam으로 제한
        guard editingPost == nil else { return }
        guard let userTeam = userTeam else { return }
        
        if let index = teams.firstIndex(of: userTeam) {
            teamPicker.selectRow(index, inComponent: 0, animated: false)
            selectedTeam = userTeam
        } else if let index = teams.firstIndex(of: "전체") {
            teamPicker.selectRow(index, inComponent: 0, animated: false)
            selectedTeam = "전체"
        }
        
        teamPicker.reloadAllComponents()
    }
    
    func fetchBadWords(completion: @escaping ([String]) -> Void) {
        Firestore.firestore().collection("badwords").getDocuments { snapshot, error in
            if let error = error {
                print("금지어 불러오기 실패:", error.localizedDescription)
                completion([])
                return
            }
            let words = snapshot?.documents.compactMap { $0.data()["word"] as? String } ?? []
            print("금지어 로딩 완료: \(words)")
            completion(words)
        }
    }
    
    func containsBadWord(_ text: String, badWords: [String]) -> Bool {
        let loweredText = text
            .lowercased()
            .replacingOccurrences(of: "[^가-힣a-z0-9]", with: "", options: .regularExpression)
        
        for badWord in badWords {
            let cleanedBadWord = badWord.lowercased().replacingOccurrences(of: "[^가-힣a-z0-9]", with: "", options: .regularExpression)
            if loweredText.contains(cleanedBadWord) {
                return true
            }
        }
        
        return false
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
        
        // 금지어 체크
        if containsBadWord(title, badWords: badWords) || containsBadWord(content, badWords: badWords) {
            showAlert(message: "금지어가 포함되어 있습니다. 내용을 수정해주세요.")
            return
        }
        
        let postData: [String: Any] = [
            "title": title,
            "content": content,
            "team": team,
            "likes": editingPost == nil ? 0 : editingPost?.likes ?? 0,
            "dislikes": editingPost == nil ? 0 : editingPost?.dislikes ?? 0,
            "commentsCount": editingPost == nil ? 0 : editingPost?.commentsCount ?? 0,
            "author": self.userNickname ?? "알 수 없음",
            "authorUid": user.uid,
            "showReportAlert": false,
            "createdAt": editingPost == nil ? Timestamp() : editingPost?.createdAt ?? Timestamp(),
            "category": "community"
        ]
        
        if let editingPost = editingPost {
            Firestore.firestore().collection("posts").document(editingPost.id).updateData(postData) { error in
                if let error = error {
                    self.showAlert(message: "글 수정 실패: \(error.localizedDescription)")
                } else {
                    self.showAlert(message: "글이 수정되었습니다.") {
                        self.navigationController?.popViewController(animated: true)
                    }
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
                    self.showAlert(message: "글이 등록되었습니다.") {
                        self.navigationController?.popViewController(animated: true)
                    }
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
    
    @objc private func textInputChanged() {
        updateSubmitButtonState()
    }
}

// MARK: - UITextViewDelegate
extension CommunityWriteVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateSubmitButtonState()
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
        let selected = teams[row]
        
        if editingPost == nil, selected != "전체", selected != userTeam {
            showAlert(message: "선택할 수 없는 팀입니다.")
            if let userTeam = userTeam, let index = teams.firstIndex(of: userTeam) {
                pickerView.selectRow(index, inComponent: 0, animated: true)
                selectedTeam = userTeam
            } else if let index = teams.firstIndex(of: "전체") {
                pickerView.selectRow(index, inComponent: 0, animated: true)
                selectedTeam = "전체"
            }
        } else {
            selectedTeam = selected
        }
    }
}
