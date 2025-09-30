//
//  CommunityWriteVC.swift
//  KleagueApp
//
//  Created by 최영건 on 7/1/25.
//

import UIKit
import SnapKit
import RxSwift
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import PhotosUI

class CommunityWriteVC: UIViewController {
    
    var editingPost: Post?
    private var collectionView: UICollectionView!
    
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
    
//    private let addImageButton = UIButton()
    private var selectedImages: [UIImage] = []
    private var existingImageUrls: [String] = []
    
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
        
        setupUI()
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
            existingImageUrls = post.imageUrls
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
                
                if (isBadTitle || isBadContent) && hasTitle && hasContent {
                    if !self.isBadWordAlertShown {
                        self.isBadWordAlertShown = true
                        self.showAlert(message: "금지어가 포함되어 있습니다. 내용을 수정해주세요.") {
                            self.isBadWordAlertShown = false
                        }
                    }
                } else {
                    self.isBadWordAlertShown = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        titleField.placeholder = "제목을 입력하세요"
        titleField.borderStyle = .roundedRect
        
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 8
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumLineSpacing = 8
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
//        addImageButton.setTitle("사진 추가", for: .normal)
//        addImageButton.setTitleColor(.systemBlue, for: .normal)
//        addImageButton.addTarget(self, action: #selector(didTapAddImage), for: .touchUpInside)
        
        submitButton.setTitle("등록하기", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        
        [titleField, contentTextView, collectionView, /*addImageButton,*/ teamPicker, submitButton].forEach {
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
        
//        addImageButton.snp.makeConstraints {
//            $0.top.equalTo(contentTextView.snp.bottom).offset(8)
//            $0.leading.equalToSuperview().inset(20)
//            $0.height.equalTo(30)
//        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(80)
        }
        
        teamPicker.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(20)
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
                $0.top.equalTo(collectionView.snp.bottom).offset(20)
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
    
    @objc private func didTapAddImage() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func uploadImages(completion: @escaping ([String]) -> Void) {
        guard !selectedImages.isEmpty else {
            completion(existingImageUrls)
            return
        }
        
        let storageRef = Storage.storage().reference().child("post_images")
        var urls: [String] = existingImageUrls
        let group = DispatchGroup()
        
        for image in selectedImages {
            group.enter()
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                group.leave()
                continue
            }
            
            let filename = UUID().uuidString + ".jpg"
            let ref = storageRef.child(filename)
            ref.putData(data, metadata: nil) { _, error in
                if let error = error {
                    print("이미지 업로드 실패:", error.localizedDescription)
                    group.leave()
                    return
                }
                
                ref.downloadURL { url, _ in
                    if let url = url {
                        urls.append(url.absoluteString)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(urls)
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
        
        if containsBadWord(title, badWords: badWords) || containsBadWord(content, badWords: badWords) {
            showAlert(message: "금지어가 포함되어 있습니다. 내용을 수정해주세요.")
            return
        }
        
        uploadImages { imageUrls in
            let postData: [String: Any] = [
                "title": title,
                "content": content,
                "team": team,
                "likes": self.editingPost?.likes ?? 0,
                "dislikes": self.editingPost?.dislikes ?? 0,
                "commentsCount": self.editingPost?.commentsCount ?? 0,
                "author": self.userNickname ?? "알 수 없음",
                "authorUid": user.uid,
                "showReportAlert": false,
                "createdAt": self.editingPost?.createdAt ?? Timestamp(),
                "category": "community",
                "imageUrls": imageUrls
            ]
            
            if let editingPost = self.editingPost {
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
                Firestore.firestore().collection("posts").addDocument(data: postData) { error in
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

// MARK: - UICollectionView
extension CommunityWriteVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.imageView.image = selectedImages[indexPath.item]
        return cell
    }
}

// MARK: - PHPickerViewControllerDelegate
extension CommunityWriteVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        let group = DispatchGroup()
        var newImages: [UIImage] = []

        for result in results {
            group.enter()
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                    if let image = reading as? UIImage {
                        newImages.append(image)
                    }
                    group.leave()
                }
            } else {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.selectedImages.append(contentsOf: newImages)
            self.collectionView.reloadData()
        }
    }
}

// MARK: - ImageCell
class ImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
