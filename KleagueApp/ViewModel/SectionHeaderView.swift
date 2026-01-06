//
//  SectionHeaderView.swift
//  KleagueApp
//
//  Created by 최영건 on 6/25/25.
//

import Foundation
import UIKit

class SectionHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    private let moreButton = UIButton()
    var onMoreTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(moreButton)
        
        titleLabel.font = .boldSystemFont(ofSize: 20)
        
        moreButton.setTitle("더보기", for: .normal)
        moreButton.setTitleColor(.systemBlue, for: .normal)
        moreButton.titleLabel?.font = .systemFont(ofSize: 14)
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }

    @objc private func moreTapped() {
        onMoreTapped?()
    }

    func setTitle(_ text: String) {
        titleLabel.text = text
    }

    func showMoreButton(_ show: Bool) {
        moreButton.isHidden = !show
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
