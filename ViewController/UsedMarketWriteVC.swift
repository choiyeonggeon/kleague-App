//
//  UsedMarketWriteVC.swift
//  KleagueApp
//
//  Created by 최영건 on 8/11/25.
//

import UIKit
import SnapKit
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

final class UsedMarketWriteVC: UIViewController {
    
    // MARK: - UI
    private let titleField = UITextField()
    private let priceField = UITextField()
    private let contentTextView = UITextView()
    private let addImageButton = UIButton(type: .system)
    private let submitButton = UIButton(type: .system)
    
    private var loadingView: UIView?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 100, height: 100)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // MARK: - Firebase
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // MARK: - State
    private var selectedImages: [UIImage] = []
    private var existingImageUrls: [String] = []
    var editingProduct: UsedProduct?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        setupCollectionView()
        fillFormIfEditing()
    }
    
    // MARK: - UI
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = editingProduct == nil ? "거래 글쓰기" : "거래 글 수정"
        
        [titleField, priceField, contentTextView, addImageButton, collectionView, submitButton]
            .forEach { view.addSubview($0) }
        
        titleField.placeholder = "제목"
        titleField.borderStyle = .roundedRect
        
        priceField.placeholder = "가격 (소수점 포함)"
        priceField.borderStyle = .roundedRect
        priceField.keyboardType = .numbersAndPunctuation
        
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 8
        contentTextView.text = "상세 설명을 입력해주세요."
        
        addImageButton.setTitle("사진 추가", for: .normal)
        
        collectionView.backgroundColor = .systemGray5
        collectionView.register(WriteImageCell.self, forCellWithReuseIdentifier: WriteImageCell.reuseId)
        collectionView.showsHorizontalScrollIndicator = false
        
        submitButton.setTitle(editingProduct == nil ? "등록하기" : "수정하기", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        
        // Layout
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
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(priceField.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(200)
        }
        addImageButton.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().inset(16)
            $0.height.equalTo(30)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(addImageButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(110)
        }
        submitButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        
        if editingProduct != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "삭제",
                style: .plain,
                target: self,
                action: #selector(deletePostTapped)
            )
        }
    }
    
    private func showLoading(_ show: Bool) {
        if show {
            let overlay = UIView(frame: view.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.center = overlay.center
            indicator.startAnimating()
            
            overlay.addSubview(indicator)
            view.addSubview(overlay)
        } else {
            loadingView?.removeFromSuperview()
            loadingView = nil
        }
    }
    
    private func setupActions() {
        addImageButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitPost), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func fillFormIfEditing() {
        guard let product = editingProduct else { return }
        titleField.text = product.title
        priceField.text = product.price
        contentTextView.text = product.description
        existingImageUrls = product.imageUrls
        collectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    @objc private func addImageTapped() {
        checkPhotoPermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                let remainingCount = 5 - (self.selectedImages.count + self.existingImageUrls.count)
                if remainingCount <= 0 {
                    self.simpleAlert("안내", "이미지는 최대 5장까지 선택할 수 있어요.")
                    return
                }
                
                var config = PHPickerConfiguration()
                config.selectionLimit = remainingCount
                config.filter = .images
                
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = self
                self.present(picker, animated: true)
            } else {
                let alert = UIAlertController(
                    title: "사진 접근 권한 필요",
                    message: "사진을 선택하려면 설정에서 사진 접근을 허용해주세요.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                })
                self.present(alert, animated: true)
            }
        }
    }
    
    private func checkPhotoPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited: completion(true)
        case .denied, .restricted: completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                completion(newStatus == .authorized || newStatus == .limited)
            }
        @unknown default: completion(false)
        }
    }
    
    @objc private func submitPost() {
        guard let user = Auth.auth().currentUser else {
            simpleAlert("로그인 필요", "글 작성은 로그인 후 가능합니다.")
            return
        }
        guard let title = titleField.text, !title.isEmpty,
              let price = priceField.text, !price.isEmpty,
              let desc = contentTextView.text, !desc.isEmpty else {
            simpleAlert("입력 필요", "모든 항목을 입력해주세요.")
            return
        }
        
        showLoading(true)
        
        uploadSelectedImages { [weak self] uploadedUrls in
            guard let self = self else { return }
            
            // 기존 이미지 + 새로 업로드된 이미지
            let finalUrls = self.existingImageUrls + uploadedUrls
            
            // 🚨 여기서 방어
            if self.selectedImages.count > 0 && uploadedUrls.isEmpty {
                self.showLoading(false)
                self.simpleAlert("업로드 실패", "선택한 사진 업로드에 실패했습니다.")
                return
            }
            
            self.savePostDocument(
                user: user,
                title: title,
                price: price,
                description: desc,
                imageUrls: finalUrls
            )
        }
    }
    
    private func uploadSelectedImages(completion: @escaping ([String]) -> Void) {
        guard !selectedImages.isEmpty, let user = Auth.auth().currentUser else {
            completion([])
            return
        }
        
        var uploaded: [String] = []
        let group = DispatchGroup()
        let storageRef = storage.reference().child("used_market/\(user.uid)")
        
        for (index, img) in selectedImages.enumerated() {
            group.enter()
            
            guard let data = img.jpegData(compressionQuality: 0.8) else {
                print("❌ JPEG 변환 실패 (index \(index))")
                group.leave()
                continue
            }
            
            let fileName = "\(UUID().uuidString)_\(index).jpg"
            let ref = storageRef.child(fileName)
            
            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"
            
            ref.putData(data, metadata: meta) { _, error in
                if let error = error {
                    print("❌ 업로드 실패 (index \(index)): \(error.localizedDescription)")
                    group.leave()
                    return
                }
                
                ref.downloadURL { url, error in
                    if let error = error {
                        print("❌ URL 가져오기 실패 (index \(index)): \(error.localizedDescription)")
                    } else if let urlStr = url?.absoluteString {
                        print("✅ 업로드 성공 (index \(index)): \(urlStr)")
                        uploaded.append(urlStr)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if uploaded.count != self.selectedImages.count {
                print("⚠️ 일부 업로드 실패: \(uploaded.count)/\(self.selectedImages.count)")
            }
            completion(uploaded)
        }
    }
    
    
    private func savePostDocument(user: User, title: String, price: String, description: String, imageUrls: [String]) {
        if let product = editingProduct {
            let update: [String: Any] = [
                "title": title,
                "price": price,
                "description": description,
                "imageUrls": imageUrls,
                "updatedAt": Timestamp(date: Date())
            ]
            db.collection("used_market").document(product.id).updateData(update) { [weak self] err in
                if err != nil {
                    self?.simpleAlert("수정 실패", err!.localizedDescription)
                } else {
                    self?.simpleAlert("완료", "거래 글이 수정되었습니다.") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            db.collection("users").document(user.uid).getDocument { [weak self] snap, _ in
                guard let self = self else { return }
                let sellerName = (snap?.data()?["nickname"] as? String) ?? (user.email ?? "판매자")
                let doc: [String: Any] = [
                    "title": title,
                    "price": price,
                    "description": description,
                    "imageUrls": imageUrls,
                    "sellerUid": user.uid,
                    "sellerName": sellerName,
                    "createdAt": Timestamp(date: Date())
                ]
                self.db.collection("used_market").addDocument(data: doc) { err in
                    if err != nil {
                        self.simpleAlert("저장 실패", err!.localizedDescription)
                    } else {
                        self.showLoading(false)
                        self.simpleAlert("완료", "거래 글이 등록되었습니다.") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func deletePostTapped() {
        guard let product = editingProduct else { return }
        let alert = UIAlertController(title: "삭제 확인", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deletePostDocument(product: product)
        })
        present(alert, animated: true)
    }
    
    private func deletePostDocument(product: UsedProduct) {
        db.collection("used_market").document(product.id).delete { [weak self] _ in
            product.imageUrls.forEach { urlStr in
                self?.storage.reference(forURL: urlStr).delete(completion: nil)
            }
            self?.simpleAlert("완료", "거래 글이 삭제되었습니다.") {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func simpleAlert(_ title: String, _ message: String, completion: (() -> Void)? = nil) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "확인", style: .default) { _ in completion?() })
        present(a, animated: true)
    }
}

// MARK: - CollectionView
extension UsedMarketWriteVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return existingImageUrls.count + selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WriteImageCell.reuseId, for: indexPath) as! WriteImageCell
        let existingCount = existingImageUrls.count
        if indexPath.item < existingCount {
            let url = existingImageUrls[indexPath.item]
            cell.configure(url: url) { [weak self] in
                self?.existingImageUrls.remove(at: indexPath.item)
                collectionView.reloadData()
            }
        } else {
            let img = selectedImages[indexPath.item - existingCount]
            cell.configure(image: img) { [weak self] in
                self?.selectedImages.remove(at: indexPath.item - existingCount)
                collectionView.reloadData()
            }
        }
        return cell
    }
}

// MARK: - PHPicker
extension UsedMarketWriteVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }
        
        let group = DispatchGroup()
        var newImages: [UIImage] = []
        
        for r in results {
            if r.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                r.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    defer { group.leave() }
                    if let img = object as? UIImage { newImages.append(img) }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            let remain = max(0, 5 - (self.existingImageUrls.count + self.selectedImages.count))
            self.selectedImages.append(contentsOf: newImages.prefix(remain))
            self.collectionView.reloadData()
        }
    }
}

// MARK: - WriteImageCell
final class WriteImageCell: UICollectionViewCell {
    static let reuseId = "WriteImageCell"
    
    private let imageView = UIImageView()
    private let deleteButton = UIButton(type: .custom)
    private var deleteAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        deleteButton.setTitle("✕", for: .normal)
        deleteButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        deleteButton.layer.cornerRadius = 12
        deleteButton.addTarget(self, action: #selector(tapDelete), for: .touchUpInside)
        deleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(4)
            $0.width.height.equalTo(24)
        }
        
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 0.5
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }
    
    func configure(image: UIImage, onDelete: @escaping () -> Void) {
        imageView.image = image
        deleteAction = onDelete
    }
    
    func configure(url: String, onDelete: @escaping () -> Void) {
        imageView.setImage(from: url) // URL -> UIImage 로딩 확장 사용
        deleteAction = onDelete
    }
    
    @objc private func tapDelete() { deleteAction?() }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
