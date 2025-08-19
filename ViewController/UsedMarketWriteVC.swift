//
//  UsedMarketWriteVC.swift
//  KleagueApp
//
//  Created by 최영건 on 8/11/25.
//

import UIKit
import SnapKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class UsedMarketWriteVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let titleLabel = UILabel()
    private let titleField = UITextField()
    private let priceField = UITextField()
    private let contentTextView = UITextView()
    private let imageView = UIImageView()
    private let submitButton = UIButton()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
    }
    
    private func setupUI() {
        
        view.backgroundColor = .white
        navigationItem.title = "거래 글쓰기"
        
        [titleField, priceField, contentTextView, imageView, submitButton].forEach { view.addSubview($0) }
        
        titleField.placeholder = "제목"
        titleField.borderStyle = .roundedRect
        priceField.placeholder = "가격 (숫자만)"
        priceField.borderStyle = .roundedRect
        priceField.keyboardType = .numberPad
        
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 8
        contentTextView.text = "상세 설명을 입력해주세요."
        
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        
        submitButton.setTitle("등록하기", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.layer.cornerRadius = 8
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.addTarget(self, action: #selector(submitPost), for: .touchUpInside)
        
        titleField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        priceField.snp.makeConstraints {
            $0.top.equalTo(titleField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(priceField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(150)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(200)
        }
        
        submitButton.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }
    
    @objc private func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage {
            selectedImage = img
            imageView.image = img
        }
    }
    
    @objc private func submitPost() {
        guard let user = Auth.auth().currentUser else {
            showSimpleAlert("로그인 필요", "글 작성은 로그인 후 가능합니다.")
            return
        }
        guard let title = titleField.text, !title.isEmpty,
              let price = priceField.text, !price.isEmpty,
              let description = contentTextView.text, !description.isEmpty else {
            showSimpleAlert("입력 필요", "모든 항목을 입력해주세요.")
            return
        }
        
        if let image = selectedImage, let data = image.jpegData(compressionQuality: 0.8) {
            let path = "used_market/\(user.uid)/\(UUID().uuidString).jpg"
            let ref = storage.reference().child(path)
            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"
            let hud = ProgressHUD.show(in: view, text: "업로드 중...")
            ref.putData(data, metadata: meta) { [weak self] _, error in
                guard let self = self else { return }
                if let error = error {
                    hud.dismiss()
                    self.showSimpleAlert("업로드 실패", error.localizedDescription)
                    return
                }
                ref.downloadURL() { url, error in
                    hud.dismiss()
                    if let error = error {
                        self.showSimpleAlert("오류", error.localizedDescription)
                        return
                    }
                    let imageUrl = url?.absoluteString ?? ""
                    self.savePostDocument(user: user, title: title, price: price, description: description, imageUrl: imageUrl)
                }
            }
        } else {
            savePostDocument(user: user, title: title, price: price, description: description, imageUrl: "")
        }
    }
    
    private func savePostDocument(user: User, title: String, price: String, description: String, imageUrl: String) {
        let userRef = db.collection("users").document(user.uid)
        userRef.getDocument { [weak self] snap, error in
            guard let self = self else { return }
            let sellerName = (snap?.data()?["nickname"] as? String) ?? (user.email ?? "판매자")
            let doc: [String: Any] = [
                "title": title,
                "price": price,
                "description": description,
                "imageUrl": imageUrl,
                "sellerName": sellerName,
                "createdAt": Timestamp(date: Date())
            ]
            self.db.collection("used_market").addDocument(data: doc) { err in
                if let err = err {
                    self.showSimpleAlert("저장 실패", err.localizedDescription)
                } else {
                    self.showSimpleAlert("완료", "거래 글이 등록되었습니다.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func showSimpleAlert(_ title: String, _ message: String, completion: (() -> Void)? = nil) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "확인", style: .default) { _ in completion?() })
        present(a, animated: true)
    }
}
