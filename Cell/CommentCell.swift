import UIKit
import SnapKit
import FirebaseAuth

class CommentCell: UITableViewCell {
    
    static let identifier = "CommentCell"
    
    private let timeLabel = UILabel()
    private let authorLabel = UILabel()
    private let commentLabel = UILabel()
    private let hideButton = UIButton()
    private let deleteButton = UIButton()
    private let blockButton = UIButton(type: .system)
    private let moreButton = UIButton(type: .system)
    private let commentReplyButtton = UIButton(type: .system)
    private let repliesStackView = UIStackView()
    
    // 권한 플래그
    var isAdmin: Bool = false
    var isAuthor: Bool = false
    
    // 액션 클로저
    var editAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    var reportAction: (() -> Void)?
    var hideAction: (() -> Void)?
    var blockAction: (() -> Void)?
    var replyAction: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 상대 시간 계산 함수
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
    
    // 권한 정보 포함하여 구성
    func configure(with comment: Comment, isBlocked: Bool, isAdmin: Bool = false, isAuthor: Bool = false) {
        authorLabel.text = comment.author
        commentLabel.text = comment.text
        blockButton.isHidden = true
        moreButton.isHidden = false
        timeLabel.text = timeAgoSinceDate(comment.createdAt)
        
        self.isAdmin = isAdmin
        self.isAuthor = isAuthor
    }
    
    private func setupUI() {
        [authorLabel, commentLabel, timeLabel, moreButton, commentReplyButtton, repliesStackView].forEach {
            contentView.addSubview($0)
        }
        
        authorLabel.font = .boldSystemFont(ofSize: 14)
        commentLabel.font = .systemFont(ofSize: 14)
        commentLabel.numberOfLines = 0
        
        moreButton.setTitle("⋯", for: .normal) // 점 3개 문자
        moreButton.titleLabel?.font = .systemFont(ofSize: 24)
        moreButton.setTitleColor(.systemGray, for: .normal)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        
        commentReplyButtton.setTitle("답글", for: .normal)
        commentReplyButtton.setTitleColor(.systemBlue, for: .normal)
        commentReplyButtton.titleLabel?.font = .systemFont(ofSize: 13)
        commentReplyButtton.addTarget(self, action: #selector(didTapReply), for: .touchUpInside)
        
        repliesStackView.axis = .vertical
        repliesStackView.spacing = 4
        
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
        
        commentReplyButtton.snp.makeConstraints {
            $0.top.equalTo(moreButton.snp.bottom).offset(4)
            $0.leading.equalTo(moreButton)
            $0.bottom.equalToSuperview().inset(8)
        }
        
        repliesStackView.snp.makeConstraints {
            $0.top.equalTo(commentReplyButtton.snp.bottom).offset(4)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }
        
        moreButton.snp.makeConstraints {
            $0.centerY.equalTo(authorLabel)
            $0.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(30)
        }
    }
    
    @objc private func didTapReply() {
        replyAction?()
    }
    
    @objc private func didTapMore() {
        guard Auth.auth().currentUser != nil else {
            findViewController()?.showAlert(title: "로그인 필요", message: "댓글 관리 기능은 로그인 후 이용 가능합니다.")
            return
        }
        guard let parentVC = findViewController() else { return }
        
        let alert = UIAlertController(title: "댓글 관리", message: nil, preferredStyle: .actionSheet)
        
        // 작성자이거나 관리자면 수정/삭제
        if isAdmin || isAuthor {
            alert.addAction(UIAlertAction(title: "수정", style: .default, handler: { _ in
                self.editAction?()
            }))
            
            if isAdmin || isAuthor {
                alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                    self.deleteAction?()
                }))
            }
        }
        
        // 관리자만 숨김 가능
        if isAdmin {
            alert.addAction(UIAlertAction(title: "숨김", style: .default, handler: { _ in
                self.hideAction?()
            }))
        }
        
        // 차단: 관리자이면서 작성자가 아닌 경우에만
        if isAdmin || !isAuthor {
            alert.addAction(UIAlertAction(title: "차단", style: .default, handler: { _ in
                self.blockAction?()
            }))
        }
        
        // 일반 사용자일 경우에만 신고
        if !isAdmin && !isAuthor {
            alert.addAction(UIAlertAction(title: "신고하기", style: .destructive, handler: { _ in
                self.reportAction?()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
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
