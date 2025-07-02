import UIKit
import SnapKit

class CommentCell: UITableViewCell {
    
    static let identifier = "CommentCell"
    
    private let timeLabel = UILabel()
    private let authorLabel = UILabel()
    private let commentLabel = UILabel()
    private let blockButton = UIButton(type: .system) // 필요 없으면 제거 가능
    private let moreButton = UIButton(type: .system)
    
    // 액션 클로저
    var editAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    var hideAction: (() -> Void)?
    var blockAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 상대 시간 계산 함수 추가
    private func timeAgoSinceDate(_ date: Date) -> String {
        let now = Date()
        let secondsAgo = Int(now.timeIntervalSince(date))
        
        if secondsAgo < 60 {
            return "방금 전"
        } else if secondsAgo < 3600 {
            return "\(secondsAgo / 60)분 전"
        } else if secondsAgo < 86400 {
            return "\(secondsAgo / 3600)시간 전"
        } else if secondsAgo < 2592000 {
            return "\(secondsAgo / 86400)일 전"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월 d일"
            return formatter.string(from: date)
        }
    }
    
    func configure(with comment: Comment, isBlocked: Bool, isAdmin: Bool = false) {
        authorLabel.text = comment.author
        commentLabel.text = comment.text
        // blockButton 숨김 처리 (더보기로 이동)
        blockButton.isHidden = true
        // moreButton 항상 보이도록
        moreButton.isHidden = false
        
        // 상대 시간으로 표시
        timeLabel.text = timeAgoSinceDate(comment.createdAt)
    }
    
    private func setupUI() {
        [authorLabel, commentLabel, timeLabel, moreButton].forEach {
            contentView.addSubview($0)
        }
        
        authorLabel.font = .boldSystemFont(ofSize: 14)
        commentLabel.font = .systemFont(ofSize: 14)
        commentLabel.numberOfLines = 0
        
        moreButton.setTitle("⋯", for: .normal) // 점 3개 문자
        moreButton.titleLabel?.font = .systemFont(ofSize: 24)
        moreButton.setTitleColor(.systemGray, for: .normal)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        
        authorLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(8)
            $0.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-8)
        }
        
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .gray
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom).offset(2)
            $0.leading.equalTo(commentLabel)
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(30)
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(authorLabel)
            $0.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(30)
        }
    }
    
    @objc private func didTapMore() {
        guard let parentVC = findViewController() else { return }
        
        let alert = UIAlertController(title: "댓글 관리", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "수정", style: .default, handler: { _ in
            self.editAction?()
        }))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.deleteAction?()
        }))
        alert.addAction(UIAlertAction(title: "숨김", style: .default, handler: { _ in
            self.hideAction?()
        }))
        alert.addAction(UIAlertAction(title: "차단/차단 해제", style: .default, handler: { _ in
            self.blockAction?()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // iPad 지원
        if let popover = alert.popoverPresentationController {
            popover.sourceView = moreButton
            popover.sourceRect = moreButton.bounds
        }
        
        parentVC.present(alert, animated: true)
    }
}

// UIView -> UIViewController 찾기 헬퍼
extension UIView {
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController { return vc }
            responder = responder?.next
        }
        return nil
    }
}
