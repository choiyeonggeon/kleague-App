//
//  UsedMarketDetailVC.swift
//  KleagueApp
//
//  Created by 최영건 on 8/12/25.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class UsedMarketDetailVC: UIViewController {
    
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 150, height: 150)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionTextView = UITextView()
    private let sellerLabel = UILabel()
    private let chatButton = UIButton()
    
    // MARK: - Properties
    var product: UsedProduct?
    private let db = Firestore.firestore()
    private var imageUrls: [String] = []
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        configureData()
        setupMoreButton()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "상품 상세"
        
        [collectionView, titleLabel, priceLabel, descriptionTextView, sellerLabel, chatButton].forEach {
            view.addSubview($0)
        }
        
        collectionView.backgroundColor = .systemGray5
        collectionView.register(MarketImageCell.self, forCellWithReuseIdentifier: "MarketImageCell")
        collectionView.showsHorizontalScrollIndicator = false
        
        titleLabel.font = .boldSystemFont(ofSize: 20)
        
        priceLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        priceLabel.textColor = .systemRed
        
        descriptionTextView.font = .systemFont(ofSize: 16)
        descriptionTextView.isEditable = false
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.cornerRadius = 6
        
        sellerLabel.font = .systemFont(ofSize: 14)
        sellerLabel.textColor = .darkGray
        
        chatButton.setTitle("채팅하기", for: .normal)
        chatButton.backgroundColor = .systemBlue
        chatButton.setTitleColor(.white, for: .normal)
        chatButton.layer.cornerRadius = 8
        chatButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(220)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(150)
        }
        sellerLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionTextView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        chatButton.snp.makeConstraints {
            $0.top.equalTo(sellerLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
    }
    
    private func configureData() {
        guard let product = product else { return }
        
        titleLabel.text = product.title
        priceLabel.text = product.price.isEmpty ? "가격 없음" : "\(product.price)원"
        descriptionTextView.text = product.description.isEmpty ? "설명 없음" : product.description
        sellerLabel.text = "판매자: \(product.sellerName)"
        
        imageUrls = product.imageUrls
        collectionView.reloadData()
    }
    
    // MARK: - Navigation Items
    private func setupMoreButton() {
        let moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(didTapMore))
        navigationItem.rightBarButtonItem = moreButton
    }
    
    @objc private func didTapMore() {
        guard let currentUser = Auth.auth().currentUser,
              let product = product else { return }
        
        let isMine = product.sellerUid == currentUser.uid
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if isMine {
            alert.addAction(UIAlertAction(title: "수정", style: .default) { _ in
                let editVC = UsedMarketWriteVC()
                editVC.editingProduct = product
                self.navigationController?.pushViewController(editVC, animated: true)
            })
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
                self.deleteProduct(product)
            })
        } else {
            alert.addAction(UIAlertAction(title: "신고하기", style: .destructive) { _ in
                self.showReasonAlert(for: product)
            })
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func showReasonAlert(for product: UsedProduct) {
        let alert = UIAlertController(title: "신고 사유", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "신고 사유를 입력해주세요" }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "신고", style: .destructive) { _ in
            if let reason = alert.textFields?.first?.text, !reason.isEmpty {
                self.reportMarketProduct(product, reason: reason)
            }
        })
        present(alert, animated: true)
    }
    
    private func deleteProduct(_ product: UsedProduct) {
        db.collection("used_market").document(product.id).delete { [weak self] error in
            if let error = error {
                print("삭제 실패: \(error.localizedDescription)")
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func reportMarketProduct(_ product: UsedProduct, reason: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let marketReportsRef = db.collection("market_reports")
        
        marketReportsRef
            .whereField("productId", isEqualTo: product.id)
            .whereField("reportedByUid", isEqualTo: currentUser.uid)
            .whereField("isResolved", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("중고마켓 신고 중복 체크 실패: \(error.localizedDescription)")
                    return
                }
                if let docs = snapshot?.documents, !docs.isEmpty {
                    self.showAlert(title: "이미 신고함", message: "이미 이 글을 신고하셨습니다.")
                    return
                }
                
                let reportData: [String: Any] = [
                    "productId": product.id,
                    "reportedUserId": product.sellerUid,
                    "reportedByUid": currentUser.uid,
                    "reportedBy": currentUser.email ?? "익명",
                    "reason": reason,
                    "createdAt": Timestamp(date: Date()),
                    "isResolved": false
                ]
                
                marketReportsRef.addDocument(data: reportData) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.showAlert(title: "신고 실패", message: error.localizedDescription)
                        } else {
                            self.showAlert(title: "신고 완료", message: "신고가 정상적으로 접수되었습니다. 관리자 확인 후 24시간 내에 조치됩니다.")
                        }
                    }
                }
            }
    }
    
    // MARK: - Chat
    @objc private func chatButtonTapped() {
        if Auth.auth().currentUser == nil {
            let alert = UIAlertController(title: "로그인이 필요합니다",
                                          message: "채팅 기능을 사용하려면 로그인해주세요.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        guard let currentUser = Auth.auth().currentUser,
              let product = product else { return }
        
        let chatVC = ChatVC(post: product, currentUserId: currentUser.uid)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "확인", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension UsedMarketDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(imageUrls.count, 5)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarketImageCell", for: indexPath) as! MarketImageCell
        let url = imageUrls[indexPath.item]
        cell.configure(url: url)
        return cell
    }
}

// MARK: - MarketImageCell
final class MarketImageCell: UICollectionViewCell {
    static let reuseId = "MarketImageCell"
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(image: UIImage) {
        imageView.image = image
    }
    
    func configure(url: String) {
        imageView.setImage(from: url)   // 👉 네가 만든 확장 함수 활용
    }
}

